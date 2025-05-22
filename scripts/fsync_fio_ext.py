#!/usr/bin/python3
"""
fsync_fio_ext.py - Benchmark tool for testing fsync/fdatasync performance on storage devices using fio

This script tests the performance of fsync() and fdatasync() system calls on different
storage devices by repeatedly writing to a file and forcing the data to be synchronized
to disk. It can also perform random read/write mixed I/O tests with sync operations.
It uses fio under the hood while maintaining the same interface as fsync.py.

Usage examples:
    # Run with default settings (fsync, 4096 bytes, 1000 iterations, sync test type)
    python fsync_fio_ext.py
    
    # Test with fdatasync instead of fsync
    python fsync_fio_ext.py --sync-method fdatasync
    
    # Test with a larger block size (1MB) for each operation
    python fsync_fio_ext.py --mmap-size 1048576
    
    # Run a quick test with fewer iterations
    python fsync_fio_ext.py --iterations 100
    
    # Specify a different output file
    python fsync_fio_ext.py --output /tmp/testfile
    
    # Run test on a specific device (automatically detects the device for the file)
    python fsync_fio_ext.py --output /mnt/ssd/testfile
    
    # Run with debug output
    python fsync_fio_ext.py --debug
    
    # Delete the test file after completion
    python fsync_fio_ext.py --cleanup

    # Run a random read/write mixed test (70% reads by default) with fsync on writes
    python fsync_fio_ext.py --test-type randrw
    
    # Run a random read/write mixed test with 50% reads and fdatasync on writes, file size 512M
    python fsync_fio_ext.py --test-type randrw --rwmixread 50 --sync-method fdatasync --file-size 512M
    
    # Combine multiple options
    python fsync_fio_ext.py --sync-method fdatasync --mmap-size 4096 --iterations 500
"""

from __future__ import print_function  # For Python 2 compatibility
import os
import sys
import argparse
import time
import subprocess
import re
import platform
import stat
import json
import tempfile
import datetime  # For timestamp in log file names
import threading
import select

# Detect Python version
PY3 = sys.version_info[0] == 3
if not PY3:
    input = raw_input


def is_safe_output_path(output_file_path, debug=False):
    """
    Checks if the proposed output file path is safe to write to.
    Prevents writing to device files or critical system directories.
    
    Args:
        output_file_path (str): The path to check
        debug (bool): Enable debug output
        
    Returns:
        bool: True if safe, False otherwise
    """
    abs_path = os.path.abspath(output_file_path)
    # Resolve symlinks to get the true path
    real_path = os.path.realpath(abs_path)

    if debug:
        print("Debug: Safety check for output path '{}'".format(output_file_path))
        print("Debug: Absolute path: '{}'".format(abs_path))
        print("Debug: Real path: '{}'".format(real_path))

    # 1. Check if the path (or what it resolves to) is an existing device file
    if os.path.exists(real_path):
        try:
            mode = os.stat(real_path).st_mode
            if stat.S_ISBLK(mode) or stat.S_ISCHR(mode):
                print("Error: Output path '{}' (resolves to '{}') is a block or character device.".format(output_file_path, real_path))
                print("Writing directly to device files can cause severe data corruption. Aborting.")
                return False
        except OSError as e:
            if debug:
                print("Debug: Could not stat existing real_path '{}': {}".format(real_path, e))
            # If stat fails, it might be a broken symlink or permissions issue.
            # It's safer to proceed with caution if it's not an obvious device path.
            # print("Warning: Could not check if existing path '{}' is a device file: {}".format(real_path, e))
            # print("Proceeding with caution, but be aware of potential risks.")
            pass # Allow proceeding if stat fails, other checks will apply

    # 2. Check if the intended path is in a dangerous top-level directory
    normalized_real_path = os.path.normpath(real_path)
    path_components = normalized_real_path.split(os.sep)

    # Check for absolute path
    if len(path_components) > 1:
        top_level_dir = path_components[1]
        
        # Highly restricted top-level directories
        critical_dirs = ["bin", "boot", "dev", "etc", "lib", "proc", "root", "sbin", "sys", "usr", "var"]
        
        if top_level_dir in critical_dirs:
            # Allow /dev/shm as it's a common tmpfs for IPC and temporary files
            # Allow /var/tmp as it's a standard temp directory
            # Allow /usr/local for user installed software and potentially test files
            allowed_exceptions = [
                (["dev", "shm"], "/dev/shm is acceptable"),
                (["var", "tmp"], "/var/tmp is acceptable"),
                (["usr", "local"], "/usr/local and subdirectories are acceptable for user data")
            ]
            
            allowed = False
            for exception_parts, reason in allowed_exceptions:
                # Check if the path starts with the exception parts
                # e.g., if path_components are ['', 'usr', 'local', 'mytest'] and exception_parts are ['usr', 'local']
                if len(path_components) > len(exception_parts) and \
                   all(path_components[i+1] == exception_parts[i] for i in range(len(exception_parts))):
                    if debug:
                        print("Debug: Path '{}' is in an allowed subdirectory: {}".format(real_path, os.sep.join([''] + exception_parts)))
                    allowed = True
                    break
            
            if not allowed:
                print("Error: Output path '{}' (resolves to '{}') appears to be within a critical system directory ({}{}{})".format(
                    output_file_path, real_path, os.sep, top_level_dir, os.sep))
                print("Writing to such locations is highly discouraged and can lead to system instability or data loss. Aborting.")
                return False

    # 3. Check if the parent directory for the output file exists
    parent_dir = os.path.dirname(abs_path)
    
    # If parent_dir is empty, it means output_file_path is a relative filename in CWD
    effective_parent_dir = parent_dir if parent_dir else os.getcwd()

    if not os.path.isdir(effective_parent_dir):
        print("Error: The parent directory '{}' for the output file '{}' does not exist or is not a directory.".format(
            effective_parent_dir, output_file_path))
        print("Please ensure the target directory exists. Aborting.")
        return False
        
    return True


def check_fio_available():
    """
    Check if fio is available on the system.
    
    Returns:
        bool: True if fio is available, False otherwise
    """
    try:
        subprocess.check_call(["fio", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except (subprocess.CalledProcessError, OSError):
        return False


def get_storage_devices():
    """
    Get a list of storage devices and their details, filtering out non-drive devices.
    
    This function runs the lsblk command to get information about storage devices,
    then filters out devices that are likely not actual drives (like CD-ROMs, floppies).
    
    Returns:
        list: A list of dictionaries containing device details
    """
    devices = []
    
    try:
        # Run lsblk command to get device information
        # Just use basic fields that are guaranteed to work across systems
        cmd = ["lsblk", "-d", "-o", "name,model,vendor,serial,type"]
        result = subprocess.check_output(cmd, universal_newlines=True)
        
        # Process the output
        lines = result.strip().split('\n')
        
        # Skip the header line
        if len(lines) > 1:
            headers = [h.lower() for h in lines[0].split()]
            
            # Process each device line
            for line in lines[1:]:
                parts = line.split(None, len(headers) - 1)
                if len(parts) >= len(headers):
                    device = {headers[i]: parts[i] for i in range(len(headers))}
                    
                    # Enhanced filtering criteria
                    should_filter = False
                    
                    # Filter based on device name patterns
                    device_name = device.get('name', '').lower()
                    if (device_name.startswith('sr') or       # CD/DVD drives
                        device_name.startswith('fd') or       # Floppy drives
                        device_name.startswith('loop') or     # Loop devices
                        device_name.startswith('ram')):       # RAM disks
                        should_filter = True
                    
                    # Filter based on device type
                    device_type = device.get('type', '').lower()
                    if device_type in ['rom', 'loop']:
                        should_filter = True
                    
                    # Filter based on model name patterns
                    model = device.get('model', '').lower()
                    if ('floppy' in model or 
                        'cdrom' in model or 
                        'virtual' in model):   # Virtual devices
                        should_filter = True
                    
                    # Filter based on vendor names
                    vendor = device.get('vendor', '').lower()
                    if 'ami' in vendor:   # AMI is often used for virtual devices
                        should_filter = True
                    
                    # Filter based on serial number patterns
                    serial = device.get('serial', '').lower()
                    if ('aaaa' in serial or  # Common pattern for virtual devices
                        'bbbb' in serial or
                        'cccc' in serial or
                        'virtual' in serial):
                        should_filter = True
                    
                    # Include device only if it passes all filters
                    if not should_filter:
                        devices.append(device)
                        
        # If we have no devices after filtering, try with fewer filters
        # This is a fallback in case our filtering was too aggressive
        if not devices:
            # Run lsblk command again
            result = subprocess.check_output(cmd, universal_newlines=True)
            
            # Process the output
            lines = result.strip().split('\n')
            
            # Skip the header line
            if len(lines) > 1:
                headers = [h.lower() for h in lines[0].split()]
                
                # Process each device line
                for line in lines[1:]:
                    parts = line.split(None, len(headers) - 1)
                    if len(parts) >= len(headers):
                        device = {headers[i]: parts[i] for i in range(len(headers))}
                        
                        # Basic filtering - just filter out obvious non-drives
                        device_type = device.get('type', '').lower()
                        device_name = device.get('name', '').lower()
                        
                        if (not device_name.startswith('loop') and 
                            not device_name.startswith('sr') and
                            device_type != 'rom'):
                            devices.append(device)
                
    except subprocess.CalledProcessError as e:
        print("Warning: Failed to get storage device information:", e)
    except Exception as e:
        print("Warning: Unexpected error getting storage information:", e)
    
    return devices


def get_device_for_path(path, devices, debug=False):
    """
    Determine which storage device a particular file path is located on.
    
    Args:
        path (str): File path to check
        devices (list): List of available storage devices
        debug (bool): Enable debug output
        
    Returns:
        dict or None: The device dictionary for the matching device, or None if not found
    """
    try:
        # Get the absolute path
        abs_path = os.path.abspath(path)
        
        # Get the directory path if the file doesn't exist yet
        if not os.path.exists(abs_path):
            abs_path = os.path.dirname(abs_path)
            # If directory doesn't exist either, use current directory
            if not abs_path or not os.path.exists(abs_path):
                abs_path = os.getcwd()
        
        # Get the mount point and device for the path
        cmd = ["df", "-P", abs_path]  # -P ensures POSIX output format
        result = subprocess.check_output(cmd, universal_newlines=True)
        
        # Parse the output (skip header)
        lines = result.strip().split('\n')
        if len(lines) > 1:
            device_path = lines[1].split()[0]
            if debug:
                print("Debug: Device path from df:", device_path)
            
            # Handle different device naming schemes
            # For NVMe drives
            if 'nvme' in device_path:
                match = re.search(r'/dev/(nvme[0-9]+n[0-9]+)p?[0-9]*', device_path)
                if match:
                    device_name = match.group(1)
                    if debug:
                        print("Debug: Matched NVMe device name:", device_name)
                    for device in devices:
                        if device.get('name') == device_name:
                            return device
            # For standard SATA/SCSI drives
            else:
                match = re.search(r'/dev/([a-zA-Z]+)[0-9]*', device_path)
                if match:
                    device_name = match.group(1)
                    if debug:
                        print("Debug: Matched standard device name:", device_name)
                    for device in devices:
                        if device.get('name') == device_name:
                            return device
            
            # If the above didn't work, try to match by comparing the beginning of device path
            for device in devices:
                device_name = device.get('name', '')
                if device_path.startswith("/dev/" + device_name):
                    return device
            
            if debug:
                print("Debug: Could not match device path", device_path, "to any known devices")
                print("Debug: Raw device path for output:", device_path)
            
            # If we still couldn't match, return a dummy device with the raw path
            return {"name": device_path, "raw_path": True}
    except Exception as e:
        if debug:
            print("Debug: Error determining storage device for path:", e)
        else:
            print("Warning: Error determining storage device for path:", e)
    
    return None


def parse_fio_status_output(line, debug=False):
    """
    Parse FIO status output line to extract progress information.
    
    Args:
        line (str): Status line from FIO
        debug (bool): Enable debug output
        
    Returns:
        dict or None: Progress information if parsed successfully, None otherwise
    """
    # FIO status output format varies, but typically includes progress percentage
    # Look for patterns like: "Jobs: 1 (f=1): [W(1)][25.0%][w=1234KiB/s][w=308 IOPS][eta 00m:30s]"
    
    # Try to extract percentage
    percent_match = re.search(r'\[(\d+\.?\d*)%\]', line)
    if percent_match:
        try:
            percentage = float(percent_match.group(1))
            if debug:
                print("Debug: Parsed progress: {:.1f}%".format(percentage))
            return {"percentage": percentage}
        except ValueError:
            pass
    
    # Try alternative format: "job_name: (groupid=0, jobs=1): err= 0: pid=12345: (25.0%) [W][r=0,w=1234,o=0,f=0][w=1234KiB/s,308iops][eta 00m:30s]"
    alt_percent_match = re.search(r'\((\d+\.?\d*)%\)', line)
    if alt_percent_match:
        try:
            percentage = float(alt_percent_match.group(1))
            if debug:
                print("Debug: Parsed progress (alt format): {:.1f}%".format(percentage))
            return {"percentage": percentage}
        except ValueError:
            pass
    
    return None


def monitor_fio_progress(process, debug=False):
    """
    Monitor FIO process and display real progress updates.
    
    Args:
        process: Subprocess running FIO
        debug (bool): Enable debug output
    """
    last_percentage = 0
    
    try:
        # Use select to check if there's data available on stderr (where FIO writes status)
        while process.poll() is None:
            # For Python 2 compatibility, use select for non-blocking read
            if hasattr(select, 'select'):
                ready, _, _ = select.select([process.stderr], [], [], 0.1)
                if ready:
                    line = process.stderr.readline()
                    if line:
                        line = line.strip()
                        if PY3 and isinstance(line, bytes): # Decode if bytes (Python 3)
                            line = line.decode('utf-8', 'ignore')

                        if debug:
                            print("Debug: FIO stderr line:", line)
                        
                        progress_info = parse_fio_status_output(line, debug)
                        if progress_info and 'percentage' in progress_info:
                            current_percentage = progress_info['percentage']
                            # Only update if we've made significant progress
                            if current_percentage >= last_percentage + 5:  # Update every 5%
                                print("Progress: {:.1f}% complete".format(current_percentage))
                                last_percentage = current_percentage
            else:
                # Fallback for systems without select (Windows)
                time.sleep(0.5)
                
    except Exception as e:
        if debug:
            print("Debug: Error monitoring FIO progress:", e)


def run_sync_test_fio(sync_method, output_file, block_size, iterations, debug=False, log_dir=None,
                        test_type='sync', rwmixread=70, file_size_str="1G"):
    """
    Run the synchronization or mixed I/O test using fio with the specified parameters.
    
    Args:
        sync_method (str): Either 'fsync' or 'fdatasync'
        output_file (str): Path to the file to write to
        block_size (int): Size of the blocks/operations in bytes
        iterations (int): Number of operations to perform
        debug (bool): Enable debug output
        log_dir (str): Directory to write log files to (None to disable logging)
        test_type (str): 'sync' for sequential write sync test, 'randrw' for random mixed R/W test
        rwmixread (int): Percentage of reads in randrw test (0-100)
        file_size_str (str): Total file size for the test (e.g., "1G", "500M")
    
    Returns:
        tuple: (elapsed_time, metrics_dict) where metrics_dict contains all the performance metrics
    """
    # Create a temporary fio job file
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.fio') as job_file:
        job_file_path = job_file.name
        
        job_name = "{}_{}_test".format(test_type, sync_method)
        fio_job_content = ""

        if test_type == 'sync':
            # Original sequential write and sync test
            fio_job_content = """
[global]
direct=1
ioengine=sync
iodepth=1
numjobs=1
group_reporting
filename={output_file}
size={block_size} 
loops={iterations}
time_based=0 
sync=1 

[{job_name}]
rw=write
bs={block_size}
{sync_method}=1 
write_bw_log={job_name}_bw.log
write_lat_log={job_name}_lat.log
write_iops_log={job_name}_iops.log
log_avg_msec=1000
            """.format(
                job_name=job_name,
                sync_method=sync_method,
                output_file=output_file,
                block_size=block_size, # For sync test, fio file size is block_size, looped
                iterations=iterations
            )
        elif test_type == 'randrw':
            # New random read/write mixed test
            # Writes in the mix will be synced using the specified sync_method
            fio_job_content = """
[global]
direct=1
ioengine=sync 
iodepth=1
numjobs=1
group_reporting
filename={output_file}
size={file_size} 
bs={block_size} 
loops={iterations} 
time_based=0
sync=1 # Ensures syncs happen for writes as per job spec

[{job_name}]
rw=randrw
rwmixread={rwmixread} 
{sync_method}=1 
write_bw_log={job_name}_write_bw.log
write_lat_log={job_name}_write_lat.log
write_iops_log={job_name}_write_iops.log
# Removed read_bw_log, read_lat_log, read_iops_log as they caused errors.
# Metrics will still be parsed from JSON output.
log_avg_msec=1000
            """.format(
                job_name=job_name,
                sync_method=sync_method,
                output_file=output_file,
                file_size=file_size_str, # For randrw, use the specified file_size
                block_size=block_size,   # block_size for each R/W operation
                iterations=iterations,
                rwmixread=rwmixread
            )
        else:
            print("Error: Unknown test type '{}'".format(test_type))
            os.unlink(job_file_path) # Clean up temp file
            return None, None

        job_file.write(fio_job_content)
    
    try:
        # Run fio with the job file and status reporting
        if debug:
            print("Debug: Running fio with job file:", job_file_path)
            print("Debug: FIO job content:\n{}".format(fio_job_content))
            print("Debug: fio command: fio", job_file_path, "--output-format=json")
        
        start_time = time.time()
        
        # Use status reporting for real progress updates
        cmd = ["fio", job_file_path, "--output-format=json"]
        
        # Python 2.7 compatible process handling
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            # universal_newlines=True # Causes issues with stderr decoding on some systems
        )
        
        try:
            print("Running {} test (sync method: {}, ops: {})...".format(test_type, sync_method, iterations))
            
            # Start a thread to monitor progress if we have threading support
            progress_thread = None
            try:
                progress_thread = threading.Thread(target=monitor_fio_progress, args=(process, debug))
                progress_thread.daemon = True
                progress_thread.start()
            except Exception as e:
                if debug:
                    print("Debug: Could not start progress monitoring thread:", e)
                print("Running test (progress monitoring unavailable)...")
            
            # Get the output from fio
            stdout_bytes, stderr_bytes = process.communicate()
            
            # Decode stdout and stderr
            stdout = stdout_bytes.decode('utf-8', 'ignore') if stdout_bytes else ""
            stderr = stderr_bytes.decode('utf-8', 'ignore') if stderr_bytes else ""

            # Wait for progress thread to finish
            if progress_thread and progress_thread.is_alive():
                progress_thread.join(timeout=1.0) # Give it a second to finish
            
            if debug:
                print("Debug: fio stdout:", stdout)
                if stderr: # Only print stderr if it's not empty
                    print("Debug: fio stderr:", stderr)
            
            # Log the raw FIO output to a file if log_dir is specified
            if log_dir:
                try:
                    # Create log directory if it doesn't exist
                    if not os.path.exists(log_dir):
                        os.makedirs(log_dir)
                    
                    # Create timestamp for log file name
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    log_file_name = os.path.join(log_dir, "fio_raw_{}_{}_{}_{}b_{}_{}.json".format(
                        test_type, sync_method, timestamp, block_size, iterations, file_size_str if test_type == 'randrw' else 'na'))
                    
                    # Write the raw JSON output to the log file
                    with open(log_file_name, 'w') as log_file:
                        log_file.write(stdout)
                        
                    if debug:
                        print("Debug: FIO output logged to", log_file_name)
                        
                except Exception as e:
                    print("Warning: Failed to log FIO output:", e)
            
            if process.returncode != 0:
                print("Error: fio command failed with return code", process.returncode)
                if stderr: # Check if stderr has content before printing
                    print("Error details:", stderr)
                return None, None
        finally:
            # Ensure the process is terminated
            if process.poll() is None:
                try:
                    process.terminate()
                    process.wait(timeout=2) # Give it a couple of seconds to terminate
                except: # subprocess.TimeoutExpired in Py3, generic except for Py2
                    process.kill()
                    process.wait()
            
        # Parse the JSON output from fio
        try:
            fio_data = json.loads(stdout)
            
            # Extract the relevant metrics
            job_data = fio_data['jobs'][0]
            
            metrics = {}
            NANO_TO_SEC = 1000000000.0
            NANO_TO_MS = 1000000.0

            # Common metrics
            metrics['job_runtime_ms'] = job_data.get('elapsed', 0) * 1000 # Fio 'elapsed' is in seconds

            # Sync performance (always present if sync operations occurred)
            sync_stats = job_data.get('sync')
            if sync_stats:
                if 'lat_ns' in sync_stats: # Newer FIO
                    sync_lat_mean = sync_stats['lat_ns'].get('mean', 0)
                    sync_lat_min = sync_stats['lat_ns'].get('min', 0)
                    sync_lat_max = sync_stats['lat_ns'].get('max', 0)
                    sync_lat_stddev = sync_stats['lat_ns'].get('stddev', 0)
                    sync_percentiles = sync_stats['lat_ns'].get('percentile', {})
                else: # Older FIO (lat is in usec)
                    sync_lat_mean = sync_stats.get('lat', 0) * 1000
                    sync_lat_min = sync_stats.get('min', 0) * 1000 # Older FIO might have min/max at top level of sync
                    sync_lat_max = sync_stats.get('max', 0) * 1000
                    sync_lat_stddev = sync_stats.get('stddev', 0) * 1000 # Older FIO might have stddev at top level
                    sync_percentiles = {} # Reconstruct or assume not available directly in this format
                    # Fallback for older fio percentiles if present (usually usec)
                    fio_sync_percentiles = sync_stats.get('percentile', {})
                    for key, value in fio_sync_percentiles.items():
                        sync_percentiles[key] = value * 1000


                metrics.update({
                    'sync_lat_ns_min': sync_lat_min,
                    'sync_lat_ns_max': sync_lat_max,
                    'sync_lat_ns_mean': sync_lat_mean,
                    'sync_lat_ns_stddev': sync_lat_stddev,
                    'sync_lat_ns_p1': sync_percentiles.get('1.000000', 0),
                    'sync_lat_ns_p50': sync_percentiles.get('50.000000', 0),
                    'sync_lat_ns_p99': sync_percentiles.get('99.000000', 0),
                    'sync_lat_sec_mean': sync_lat_mean / NANO_TO_SEC if sync_lat_mean else 0,
                    'sync_lat_sec_p99': sync_percentiles.get('99.000000', 0) / NANO_TO_SEC if sync_percentiles.get('99.000000', 0) else 0,
                })


            if test_type == 'sync' or 'write' in job_data: # 'sync' test is write-only
                write_stats = job_data['write']
                metrics.update({
                    'write_iops': write_stats.get('iops', 0),
                    'write_bw_kibytes': write_stats.get('bw', 0),  # KiB/s
                    'write_bw_bytes': write_stats.get('bw_bytes', write_stats.get('bw', 0) * 1024), # B/s, fallback to bw * 1024
                    'write_lat_ns_mean': write_stats.get('lat_ns', {}).get('mean', write_stats.get('usr_cpu', -1)), # usr_cpu as fallback if lat_ns not there
                })
                bw_bytes = metrics['write_bw_bytes']
                metrics['write_bw_mib_s'] = bw_bytes / (1024.0 * 1024.0)
                metrics['write_bw_mb_s'] = bw_bytes / (1000.0 * 1000.0)
                # If job_runtime_ms is not directly available from job_data['elapsed'], use write runtime
                if metrics['job_runtime_ms'] == 0 and 'runtime' in write_stats:
                     metrics['job_runtime_ms'] = write_stats['runtime'] # runtime in msec


            if test_type == 'randrw' and 'read' in job_data:
                read_stats = job_data['read']
                metrics.update({
                    'read_iops': read_stats.get('iops', 0),
                    'read_bw_kibytes': read_stats.get('bw', 0), # KiB/s
                    'read_bw_bytes': read_stats.get('bw_bytes', read_stats.get('bw',0)*1024), # B/s
                    'read_lat_ns_mean': read_stats.get('lat_ns', {}).get('mean', -1),
                })
                read_bw_bytes = metrics['read_bw_bytes']
                metrics['read_bw_mib_s'] = read_bw_bytes / (1024.0 * 1024.0)
                metrics['read_bw_mb_s'] = read_bw_bytes / (1000.0 * 1000.0)
                # If job_runtime_ms is not directly available from job_data['elapsed'], use read runtime if write runtime was also 0
                if metrics['job_runtime_ms'] == 0 and 'runtime' in read_stats:
                     metrics['job_runtime_ms'] = read_stats['runtime'] # runtime in msec
            
            # Get the total elapsed time
            elapsed_time = time.time() - start_time
            
            # Log the parsed metrics if log_dir is specified
            if log_dir:
                try:
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    metrics_log_file = os.path.join(log_dir, "fio_metrics_{}_{}_{}_{}b_{}_{}.txt".format(
                        test_type, sync_method, timestamp, block_size, iterations, file_size_str if test_type == 'randrw' else 'na'))
                    
                    with open(metrics_log_file, 'w') as log_file:
                        log_file.write("FIO Metrics Summary ({}, {}):\n".format(test_type, sync_method))
                        log_file.write("===================================\n")
                        log_file.write("Total script time: {:.2f} seconds\n".format(elapsed_time))
                        log_file.write("Operations: {}\n".format(iterations))
                        log_file.write("Block size: {} bytes\n".format(block_size))
                        if test_type == 'randrw':
                            log_file.write("File size: {}\n".format(file_size_str))
                            log_file.write("Read mix: {}%\n".format(rwmixread))

                        if 'write_iops' in metrics:
                            log_file.write("\n--- Write Performance ---\n")
                            log_file.write("Write IOPS: {:.2f}\n".format(metrics['write_iops']))
                            log_file.write("Write Bandwidth: {:.2f} MiB/s ({:.2f} MB/s)\n".format(
                                metrics.get('write_bw_mib_s',0), metrics.get('write_bw_mb_s',0)))
                            if metrics.get('write_lat_ns_mean', -1) != -1:
                                log_file.write("Write Latency (avg): {:.3f} ms\n".format(metrics['write_lat_ns_mean'] / NANO_TO_MS))
                        
                        if 'read_iops' in metrics:
                            log_file.write("\n--- Read Performance ---\n")
                            log_file.write("Read IOPS: {:.2f}\n".format(metrics['read_iops']))
                            log_file.write("Read Bandwidth: {:.2f} MiB/s ({:.2f} MB/s)\n".format(
                                metrics.get('read_bw_mib_s',0), metrics.get('read_bw_mb_s',0)))
                            if metrics.get('read_lat_ns_mean', -1) != -1:
                                 log_file.write("Read Latency (avg): {:.3f} ms\n".format(metrics['read_lat_ns_mean'] / NANO_TO_MS))

                        if 'sync_lat_sec_mean' in metrics:
                            log_file.write("\n--- Sync Performance (for writes) ---\n")
                            log_file.write("Sync latency (min): {:.9f} seconds\n".format(metrics.get('sync_lat_ns_min',0) / NANO_TO_SEC))
                            log_file.write("Sync latency (avg): {:.9f} seconds\n".format(metrics.get('sync_lat_sec_mean',0)))
                            log_file.write("Sync latency (max): {:.9f} seconds\n".format(metrics.get('sync_lat_ns_max',0) / NANO_TO_SEC))
                            log_file.write("Sync latency (p99): {:.9f} seconds\n".format(metrics.get('sync_lat_sec_p99',0)))
                            log_file.write("Sync latency (stddev): {:.9f} seconds\n".format(metrics.get('sync_lat_ns_stddev',0) / NANO_TO_SEC))
                            if metrics.get('sync_lat_sec_mean',0) > 0:
                                log_file.write("Theoretical max sync ops/s (based on avg sync lat): {:.2f}\n".format(1.0 / metrics['sync_lat_sec_mean']))
                        
                        log_file.write("\nFIO job runtime: {:.3f} seconds\n".format(metrics.get('job_runtime_ms', 0) / 1000.0))
                        log_file.write("\nRaw Metrics Dictionary:\n")
                        for key, value in sorted(metrics.items()):
                            log_file.write("{}: {}\n".format(key, value))
                    
                    if debug:
                        print("Debug: Metrics logged to", metrics_log_file)
                        
                except Exception as e:
                    print("Warning: Failed to log metrics:", e)
            
            print("Test completed successfully!")
            return elapsed_time, metrics
            
        except (ValueError, KeyError, IndexError) as e: # Added IndexError for fio_data['jobs'][0]
            if debug:
                print("Debug: Error parsing fio JSON output: ", str(e))
                print("Debug: Received FIO stdout for parsing:\n{}".format(stdout))
            print("Error: Failed to parse fio results: ", str(e))
            return None, None
            
    except (subprocess.CalledProcessError, OSError) as e:
        print("Error running fio command:", e)
        return None, None
    finally:
        # Clean up the temporary job file
        try:
            os.unlink(job_file_path)
        except OSError: # Can be FileNotFoundError in Python 3
            pass


def print_system_info():
    """
    Print system information relevant to storage performance.
    """
    print("\n" + "="*60)
    print("System Information")
    print("="*60)
    
    # Get distribution name directly, if possible
    distro_name = "Unknown"
    try:
        if os.path.exists("/etc/os-release"):
            with open("/etc/os-release") as f:
                for line in f:
                    if line.startswith("PRETTY_NAME="):
                        distro_name = line.split("=", 1)[1].strip().strip('"')
                        break
        elif platform.system() == "Linux": # Fallback for other Linux if /etc/os-release not found
            distro_name = " ".join(platform.linux_distribution()) if hasattr(platform, 'linux_distribution') else "Linux (Unknown Distro)"
        else:
            distro_name = platform.system()

    except: # Broad except for any OS-specific file I/O or platform module issues
        pass
    
    # Print OS (showing distro as the OS)
    print("OS:            " + distro_name)
    
    # Print kernel version
    print("Kernel:        " + platform.release())
    
    # CPU information
    try:
        cpu_info_val = "Unknown"
        if platform.system() == "Linux" and os.path.exists("/proc/cpuinfo"):
            with open("/proc/cpuinfo") as f:
                cpu_info_content = f.read()
            cpu_model_match = re.search(r"model name\s+:\s+(.*)", cpu_info_content)
            if cpu_model_match:
                cpu_info_val = cpu_model_match.group(1).strip()
        else: # Fallback for non-Linux or if /proc/cpuinfo fails
            cpu_info_val = platform.processor()
        print("CPU:           " + cpu_info_val)

    except:
        if platform.processor(): # Final fallback
             print("CPU:           " + platform.processor())
        else:
            print("CPU:           Unknown")

    # Memory information
    try:
        mem_gb_val = "Unknown"
        if platform.system() == "Linux" and os.path.exists("/proc/meminfo"):
            with open("/proc/meminfo") as f:
                for line in f:
                    if line.startswith("MemTotal:"):
                        mem_kb = int(line.split()[1])
                        mem_gb = mem_kb / (1024.0 * 1024.0)
                        mem_gb_val = "{:.2f} GB".format(mem_gb)
                        break
        print("Memory:        " + mem_gb_val)
    except:
         print("Memory:        Unknown")
    
    print("="*60)


def print_storage_devices(devices):
    """
    Print a formatted table of storage devices.
    
    Args:
        devices (list): List of device dictionaries
    """
    print("\n" + "="*60)
    print("Storage Devices")
    print("="*60)
    
    if not devices:
        print("No storage devices detected or lsblk command not available.")
        print("="*60)
        return
    
    # Get all possible keys from all devices
    all_keys = set()
    for device in devices:
        all_keys.update(device.keys())
    
    # Choose which keys to display and in what order
    # Ensure 'name' is first if present
    display_keys = ["name", "model", "vendor", "serial", "type"]
    # Filter keys to only those present in all_keys, maintaining order
    display_keys = [k for k in display_keys if k in all_keys] 
    # Add any other keys not already in display_keys
    for k in sorted(list(all_keys)):
        if k not in display_keys:
            display_keys.append(k)

    # Create a format string for the table
    col_widths = {}
    for key in display_keys:
        # Get the maximum width needed for this column
        max_width = len(key) # Start with header length
        for device in devices:
            if key in device and device[key] is not None: # Check for None
                max_width = max(max_width, len(str(device[key])))
        col_widths[key] = max_width
    
    # Print the header
    header_parts = []
    for key in display_keys:
        header_parts.append("{0:{1}}".format(key.upper(), col_widths[key]))
    header = "  ".join(header_parts)
    print(header)
    print("-" * len(header))
    
    # Print each device
    for device in devices:
        row_parts = []
        for key in display_keys:
            value = device.get(key, '') # Default to empty string if key missing
            if value is None: value = '' # Ensure None is printed as empty string
            row_parts.append("{0:{1}}".format(str(value), col_widths[key]))
        row = "  ".join(row_parts)
        print(row)
    
    print("="*60)


def main():
    """
    Main function to parse arguments and run the synchronization test.
    
    The function sets up the argument parser, validates inputs, runs the test,
    and displays the results.
    """
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description='Test fsync/fdatasync performance or random R/W mix performance on storage devices using fio',
        epilog='For more information, see: https://www.percona.com/blog/fsync-performance-storage-devices/'
    )
    parser.add_argument('--test-type', choices=['sync', 'randrw'], default='sync',
                      help='Type of test to run: "sync" for sequential write + fsync/fdatasync test (default), '
                           '"randrw" for random read/write mixed I/O test with sync on writes.')
    parser.add_argument('--sync-method', choices=['fsync', 'fdatasync'], default='fsync',
                      help='Sync method to use for writes (fsync or fdatasync, default: fsync)')
    parser.add_argument('--mmap-size', type=int, default=4096,
                      help='Size of I/O operations in bytes (fio block size, default: 4096)')
    parser.add_argument('--iterations', type=int, default=1000,
                      help='Number of I/O operations (fio loops, default: 1000)')
    parser.add_argument('--output', default='testfile.fio',
                      help='Output file name for fio (default: testfile.fio)')
    parser.add_argument('--file-size', default='1G',
                      help='Total file size for fio test (e.g., 1G, 500M, default: 1G). '
                           'Primarily used for "randrw" test type. For "sync" test, fio uses mmap-size as file size and loops over it.')
    parser.add_argument('--rwmixread', type=int, default=70,
                      help='Percentage of reads in "randrw" test type (0-100, default: 70)')
    parser.add_argument('--log-dir', default=None,
                      help='Directory to write log files (default: disabled)')
    parser.add_argument('--debug', action='store_true',
                      help='Enable debug output')
    parser.add_argument('--cleanup', action='store_true',
                      help='Delete the test file after completion')
    parser.add_argument('--force', action='store_true',
                      help='Bypass safety checks (USE WITH EXTREME CAUTION)')
    parser.add_argument('--non-interactive', action='store_true',
                      help='Skip prompts for scripting')
    args = parser.parse_args()

    # Define original global defaults (must match those in add_argument)
    # These are used to check if the user supplied a specific value or if we're using the global default
    original_mmap_size_default = 4096
    original_iterations_default = 1000
    original_file_size_default = '1G'

    # Define the desired defaults specifically for 'randrw' mode
    randrw_mmap_size_default = 16384
    randrw_iterations_default = 1
    randrw_file_size_default = '1G'

    if args.test_type == 'randrw':
        # If --mmap-size was not specified by the user for this randrw run,
        # (i.e., it's still the original global default), then apply the randrw-specific default.
        if args.mmap_size == original_mmap_size_default:
            args.mmap_size = randrw_mmap_size_default
            if args.debug:
                print("Debug: Using randrw-specific default for --mmap-size: {}".format(args.mmap_size))

        # If --iterations was not specified by the user for this randrw run,
        # then apply the randrw-specific default.
        if args.iterations == original_iterations_default:
            args.iterations = randrw_iterations_default
            if args.debug:
                print("Debug: Using randrw-specific default for --iterations: {}".format(args.iterations))

        # If --file-size was not specified by the user for this randrw run,
        # then apply the randrw-specific default.
        if args.file_size == original_file_size_default:
            args.file_size = randrw_file_size_default
            if args.debug:
                print("Debug: Using randrw-specific default for --file-size: {}".format(args.file_size))

    # Check if fio is available
    if not check_fio_available():
        print("Error: fio is not installed or not in PATH. Please install fio first.")
        print("Example install: sudo yum install -y fio  OR  sudo apt-get install -y fio")
        sys.exit(1)
    
    # Validate arguments
    if args.mmap_size <= 0:
        print("Error: I/O operation size (mmap-size) must be greater than 0")
        sys.exit(1)
    
    if args.iterations <= 0:
        print("Error: Number of operations (iterations) must be greater than 0")
        sys.exit(1)

    if args.test_type == 'randrw':
        if not (0 <= args.rwmixread <= 100):
            print("Error: Read mix percentage (rwmixread) must be between 0 and 100.")
            sys.exit(1)
        if not re.match(r"^\d+[KMGTkmgt]?B?$", args.file_size): # Basic check for fio size format
             print("Error: Invalid file-size format. Use num[K|M|G|T]B (e.g., 1G, 512M, 1024K).")
             sys.exit(1)


    # Safety checks for the output file
    if not args.force and not is_safe_output_path(args.output, args.debug):
        print("\nIf you're absolutely sure you want to proceed, run again with --force")
        print("WARNING: Using --force can potentially cause system damage or data loss!")
        sys.exit(1)
    
    # Check if running as root, warn user
    # os.geteuid() is not available on Windows.
    if hasattr(os, 'geteuid') and os.geteuid() == 0:
        print("-" * 60)
        print("WARNING: This script is running as root!")
        print("Please be absolutely sure that the output path is correct:")
        print("  Output file: {}".format(os.path.abspath(args.output)))
        print("Incorrect paths can lead to severe data loss or system damage.")
        
        # Ask for confirmation if not forcing
        if not args.force and not args.non_interactive:
            try:
                confirm = input("Type 'yes' to proceed if you are sure: ")
                if confirm.lower() != 'yes':
                    print("Aborting.")
                    sys.exit(1)
            except (KeyboardInterrupt, EOFError): # EOFError for piped input
                print("\nAborted.")
                sys.exit(1)
        print("-" * 60)
    
    # Print system information
    print_system_info()
    
    # Get and display storage devices
    devices = get_storage_devices()
    print_storage_devices(devices)
    
    # Determine which device will be used for the test
    test_device = get_device_for_path(args.output, devices, args.debug)
    
    # Choose the appropriate sync method
    sync_method = args.sync_method
    
    print("\n" + "="*60)
    print("FIO Storage Performance Test")
    print("="*60)
    print("Test Type:    " + args.test_type)
    print("Sync method:  " + sync_method + " (for writes)")
    print("Op size:      " + str(args.mmap_size) + " bytes (fio bs)")
    print("Operations:   " + str(args.iterations) + " (fio loops)")
    if args.test_type == 'randrw':
        print("File size:    " + args.file_size + " (fio size)")
        print("Read mix %:   " + str(args.rwmixread))
    print("Output file:  " + args.output)
    
    if test_device:
        if test_device.get('raw_path', False):
            print("Device:       " + test_device.get('name', 'unknown') + " (determined from path)")
        else:
            print("Device:       /dev/" + test_device.get('name', 'unknown'))
            model = test_device.get('model', '').strip()
            if model:
                print("Model:        " + model)
            vendor = test_device.get('vendor', '').strip()
            if vendor:
                print("Vendor:       " + vendor)
    else:
        # Try direct device determination as a fallback if get_device_for_path failed
        try:
            # Ensure output_dir exists or use cwd
            output_dir_abs = os.path.dirname(os.path.abspath(args.output))
            if not os.path.exists(output_dir_abs):
                 output_dir_abs = os.getcwd()

            # Get the device from df command directly
            cmd = ["df", "-P", output_dir_abs]
            result = subprocess.check_output(cmd, universal_newlines=True)
            
            # Parse the output (skip header)
            lines = result.strip().split('\n')
            if len(lines) > 1:
                device_path = lines[1].split()[0]
                print("Device:       " + device_path + " (determined from path using df)")
                
                # Try to get device info for NVMe drives
                if 'nvme' in device_path and devices: # Check if devices list is populated
                    for device_info in devices: # Renamed to avoid conflict with 'device' variable
                        # Match if device_path like /dev/nvme0n1p1 ends with device name like nvme0n1
                        if device_path.startswith("/dev/" + device_info.get('name', '')):
                            model = device_info.get('model', '').strip()
                            if model: print("Model:        " + model)
                            vendor = device_info.get('vendor', '').strip()
                            if vendor: print("Vendor:       " + vendor)
                            break 
        except Exception as e:
            if args.debug:
                print("Debug: Error in fallback device detection:", e)
            print("Device:       Unknown (unable to determine storage device)")
    
    print("="*60 + "\n")
    
    # Run the test
    try:
        elapsed_time, metrics = run_sync_test_fio(
            sync_method,
            args.output,
            args.mmap_size,
            args.iterations,
            args.debug,
            args.log_dir,
            args.test_type,
            args.rwmixread,
            args.file_size
        )
        
        if elapsed_time is None or metrics is None:
            print("Test failed to execute properly.")
            sys.exit(1)
        
        # Make sure elapsed_time is valid and not too small
        if elapsed_time <= 0.001:  # Less than 1 millisecond is suspiciously fast
            print("\nWarning: Test completed very quickly. Results may not reflect sustained performance.")
            elapsed_time = max(0.001, elapsed_time) # Use a minimum for calculations
        
        # Display results
        NANO_TO_SEC = 1000000000.0
        NANO_TO_MS = 1000000.0

        print("\n" + "="*80)
        print("Test Results ({}, {}):".format(args.test_type, args.sync_method))
        print("="*80)
        print("Total script time:       {:.2f} seconds".format(elapsed_time))
        print("Operations requested:    {}".format(args.iterations))
        
        if args.test_type == 'sync' or 'write_iops' in metrics:
            print("\n--- Write Performance ---")
            print("Write IOPS:              {:.2f}".format(metrics.get('write_iops', 0)))
            print("Write Bandwidth:         {:.2f} MiB/s ({:.2f} MB/s)".format(
                metrics.get('write_bw_mib_s', 0), metrics.get('write_bw_mb_s', 0)))
            if metrics.get('write_lat_ns_mean', -1) != -1:
                print("Write Latency (avg):     {:.3f} ms".format(metrics['write_lat_ns_mean'] / NANO_TO_MS))

        if args.test_type == 'randrw' and 'read_iops' in metrics:
            print("\n--- Read Performance ---")
            print("Read IOPS:               {:.2f}".format(metrics.get('read_iops', 0)))
            print("Read Bandwidth:          {:.2f} MiB/s ({:.2f} MB/s)".format(
                metrics.get('read_bw_mib_s', 0), metrics.get('read_bw_mb_s', 0)))
            if metrics.get('read_lat_ns_mean', -1) != -1:
                 print("Read Latency (avg):      {:.3f} ms".format(metrics['read_lat_ns_mean'] / NANO_TO_MS))
        
        if 'sync_lat_sec_mean' in metrics:
            print("\n--- Sync Performance (for writes) ---")
            print("Sync latency (min):      {:.9f} seconds".format(metrics.get('sync_lat_ns_min',0) / NANO_TO_SEC))
            print("Sync latency (avg):      {:.9f} seconds".format(metrics.get('sync_lat_sec_mean',0)))
            print("Sync latency (max):      {:.9f} seconds".format(metrics.get('sync_lat_ns_max',0) / NANO_TO_SEC))
            print("Sync latency (p99):      {:.9f} seconds".format(metrics.get('sync_lat_sec_p99',0)))
            print("Sync latency (stddev):   {:.9f} seconds".format(metrics.get('sync_lat_ns_stddev',0) / NANO_TO_SEC))
            if metrics.get('sync_lat_sec_mean',0) > 0:
                ops_per_sec = 1.0 / metrics['sync_lat_sec_mean']
                print("Theoretical max sync ops/s: {:.2f} (based on avg sync latency)".format(ops_per_sec))
        
        print("\nFIO job runtime:         {:.3f} seconds".format(metrics.get('job_runtime_ms', 0) / 1000.0))
        
        if args.log_dir:
            print("Log directory:           {}".format(args.log_dir))
        
        print("="*80)
        
        # Cleanup if requested
        if args.cleanup:
            try:
                # FIO might create multiple files if log files are in the same dir as output
                # and share the same base name. Best to just remove the main output file.
                if os.path.exists(args.output):
                    os.unlink(args.output)
                    print("\nCleanup: Removed test file '{}'".format(args.output))
                else:
                    if args.debug:
                        print("\nDebug Cleanup: Test file '{}' not found for removal.".format(args.output))

            except Exception as e:
                print("\nError during cleanup: Could not remove test file '{}': {}".format(args.output, e))
    except Exception as e:
        print("Error running test:", e)
        if args.debug:
            import traceback
            traceback.print_exc()
        sys.exit(1) # Exit with error if the test encounters an unhandled exception


if __name__ == "__main__":
    main()