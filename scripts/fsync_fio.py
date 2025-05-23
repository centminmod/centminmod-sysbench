#!/usr/bin/python3
"""
fsync_fio.py - Benchmark tool for testing fsync/fdatasync performance on storage devices using fio

This script tests the performance of fsync() and fdatasync() system calls on different
storage devices by repeatedly writing to a file and forcing the data to be synchronized
to disk. It uses fio under the hood while maintaining the same interface as fsync.py.

Usage examples:
    # Run with default settings (fsync, 4096 bytes, 1000 iterations)
    python fsync_fio.py --non-interactive --force
    
    # Test with fdatasync instead of fsync
    python fsync_fio.py --sync-method fdatasync --non-interactive --force
    
    # Test with a larger block size (1MB)
    python fsync_fio.py --mmap-size 1048576 --non-interactive --force
    
    # Run a quick test with fewer iterations
    python fsync_fio.py --iterations 100 --non-interactive --force
    
    # Specify a different output file
    python fsync_fio.py --output /tmp/testfile --non-interactive --force
    
    # Combine multiple options
    python fsync_fio.py --sync-method fdatasync --mmap-size 4096 --iterations 500 --non-interactive --force
    
    # Run test on a specific device (automatically detects the device for the file)
    python fsync_fio.py --output /mnt/ssd/testfile --non-interactive --force
    
    # Run with debug output
    python fsync_fio.py --debug --non-interactive --force
    
    # Delete the test file after completion
    python fsync_fio.py --cleanup --non-interactive --force
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
            print("Warning: Could not check if existing path '{}' is a device file: {}".format(real_path, e))
            print("Proceeding with caution, but be aware of potential risks.")

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
            allowed_exceptions = [
                (["dev", "shm"], "/dev/shm is acceptable"),
                (["var", "tmp"], "/var/tmp is acceptable")
            ]
            
            allowed = False
            for exception_parts, reason in allowed_exceptions:
                if (len(path_components) > len(exception_parts) and 
                    path_components[1:len(exception_parts)+1] == exception_parts):
                    if debug:
                        print("Debug: Path '{}' is in {}, which is {}".format(real_path, os.sep.join([''] + exception_parts), reason))
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


def run_sync_test_fio(sync_method, output_file, block_size, iterations, debug=False, log_dir=None):
    """
    Run the synchronization test using fio with the specified parameters.
    
    Args:
        sync_method (str): Either 'fsync' or 'fdatasync'
        output_file (str): Path to the file to write to
        block_size (int): Size of the blocks in bytes
        iterations (int): Number of write and sync operations to perform
        debug (bool): Enable debug output
        log_dir (str): Directory to write log files to (None to disable logging)
    
    Returns:
        tuple: (elapsed_time, metrics_dict) where metrics_dict contains all the performance metrics
    """
    # Create a temporary fio job file
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.fio') as job_file:
        job_file_path = job_file.name
        
        # Write the fio job file content
        job_file.write("""
[global]
direct=1
sync=1
ioengine=sync
iodepth=1
numjobs=1
group_reporting
size={block_size}
loops={iterations}
runtime=3600
time_based=0

[{sync_method}_test]
rw=write
bs={block_size}
{sync_method}=1
filename={output_file}
write_bw_log={sync_method}_bw.log
write_lat_log={sync_method}_lat.log
write_iops_log={sync_method}_iops.log
log_avg_msec=1000
        """.format(
            sync_method=sync_method,
            output_file=output_file,
            block_size=block_size,
            iterations=iterations
        ))
    
    try:
        # Run fio with the job file and status reporting
        if debug:
            print("Debug: Running fio with job file:", job_file_path)
            print("Debug: fio command: fio", job_file_path, "--output-format=json")
        
        start_time = time.time()
        
        # Use status reporting for real progress updates
        cmd = ["fio", job_file_path, "--output-format=json"]
        
        # Python 2.7 compatible process handling
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
        )
        
        try:
            print("Running {} test with {} iterations...".format(sync_method, iterations))
            
            # Start a thread to monitor progress if we have threading support
            progress_thread = None
            # try:
            #     progress_thread = threading.Thread(target=monitor_fio_progress, args=(process, debug))
            #     progress_thread.daemon = True
            #     progress_thread.start()
            # except Exception as e:
            #     if debug:
            #         print("Debug: Could not start progress monitoring thread:", e)
            #     print("Running test (progress monitoring unavailable)...")
            
            # Get the output from fio
            stdout, stderr = process.communicate()
            
            # Wait for progress thread to finish
            if progress_thread and progress_thread.is_alive():
                progress_thread.join(timeout=1.0)
            
            if debug:
                print("Debug: fio stdout:", stdout)
                if stderr:
                    print("Debug: fio stderr:", stderr)
            
            # Log the raw FIO output to a file if log_dir is specified
            if log_dir:
                try:
                    # Create log directory if it doesn't exist
                    if not os.path.exists(log_dir):
                        os.makedirs(log_dir)
                    
                    # Create timestamp for log file name
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    log_file_name = os.path.join(log_dir, "fio_{}_{}_{}b_{}.json".format(
                        sync_method, timestamp, block_size, iterations))
                    
                    # Write the raw JSON output to the log file
                    with open(log_file_name, 'w') as log_file:
                        log_file.write(stdout)
                        
                    if debug:
                        print("Debug: FIO output logged to", log_file_name)
                        
                except Exception as e:
                    print("Warning: Failed to log FIO output:", e)
            
            if process.returncode != 0:
                print("Error: fio command failed with return code", process.returncode)
                if stderr:
                    print("Error details:", stderr)
                return None, None
        finally:
            # Ensure the process is terminated
            if process.poll() is None:
                process.terminate()
                process.wait()
            
        # Parse the JSON output from fio
        try:
            fio_data = json.loads(stdout)
            
            # Extract the relevant metrics
            job_data = fio_data['jobs'][0]
            write_stats = job_data['write']
            
            # Get sync stats
            sync_stats = job_data['sync']
            
            # For CentOS 7 compatibility (Python 2.7), avoid using underscores in numeric literals
            NANO_TO_SEC = 1000000000  # 1 billion nanoseconds in a second
            NANO_TO_MS = 1000000      # 1 million nanoseconds in a millisecond
            
            # Check if we're using newer FIO (3.16+) with lat_ns or older FIO with just 'lat'
            if 'lat_ns' in sync_stats:
                # Newer FIO format
                sync_lat_mean = sync_stats['lat_ns'].get('mean', 0)
                sync_lat_min = sync_stats['lat_ns'].get('min', 0)
                sync_lat_max = sync_stats['lat_ns'].get('max', 0)
                sync_lat_stddev = sync_stats['lat_ns'].get('stddev', 0)
                
                # Handle percentiles which could be in different formats
                percentiles = sync_stats['lat_ns'].get('percentile', {})
            else:
                # Older FIO format - convert microseconds to nanoseconds
                sync_lat_mean = sync_stats.get('lat', 0) * 1000
                sync_lat_min = sync_stats.get('lat_min', 0) * 1000
                sync_lat_max = sync_stats.get('lat_max', 0) * 1000
                sync_lat_stddev = sync_stats.get('lat_stddev', 0) * 1000
                
                # Handle percentiles which could be in different formats
                percentiles = {}
                if 'percentile' in sync_stats:
                    for key, value in sync_stats['percentile'].items():
                        # Convert microseconds to nanoseconds
                        percentiles[key] = value * 1000
            
            # Collect all the metrics in a dictionary
            metrics = {
                # Write performance
                'write_iops': write_stats.get('iops', 0),
                'write_bw_kibytes': write_stats.get('bw', 0),  # KiB/s
                'write_bw_bytes': write_stats.get('bw_bytes', 0),  # B/s
                
                # Sync performance
                'sync_lat_ns_min': sync_lat_min,
                'sync_lat_ns_max': sync_lat_max,
                'sync_lat_ns_mean': sync_lat_mean,
                'sync_lat_ns_stddev': sync_lat_stddev,
                
                # Percentile data if available
                'sync_lat_ns_p1': percentiles.get('1.000000', 0),
                'sync_lat_ns_p50': percentiles.get('50.000000', 0),
                'sync_lat_ns_p99': percentiles.get('99.000000', 0),
                
                # Convert to more readable formats
                'sync_lat_sec_mean': sync_lat_mean / float(NANO_TO_SEC),  # seconds
                'sync_lat_sec_p99': percentiles.get('99.000000', 0) / float(NANO_TO_SEC),  # seconds
                
                # Runtime
                'runtime_ms': job_data['write'].get('runtime', job_data.get('elapsed', 0) * 1000),
            }
            
            # Calculate human readable bandwidth values
            bw_bytes = metrics['write_bw_bytes']
            if bw_bytes > 0:
                metrics['write_bw_mib_s'] = bw_bytes / float(1024 * 1024)  # MiB/s
                metrics['write_bw_mb_s'] = bw_bytes / float(1000 * 1000)   # MB/s
            else:
                # Use fallback calculation from kibytes if bw_bytes is not available (older FIO)
                bw_kibytes = metrics['write_bw_kibytes']
                metrics['write_bw_mib_s'] = bw_kibytes / float(1024)  # KiB -> MiB
                metrics['write_bw_mb_s'] = (bw_kibytes * 1024) / float(1000 * 1000)  # KiB -> B -> MB
            
            
            # Get the total elapsed time
            elapsed_time = time.time() - start_time
            
            # Log the parsed metrics if log_dir is specified
            if log_dir:
                try:
                    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                    metrics_log_file = os.path.join(log_dir, "fio_metrics_{}_{}_{}b_{}.txt".format(
                        sync_method, timestamp, block_size, iterations))
                    
                    with open(metrics_log_file, 'w') as log_file:
                        log_file.write("FIO Metrics Summary:\n")
                        log_file.write("===================\n")
                        log_file.write("Total time: {:.2f} seconds\n".format(elapsed_time))
                        log_file.write("Operations: {}\n".format(iterations))
                        log_file.write("Write IOPS: {:.2f}\n".format(metrics['write_iops']))
                        log_file.write("Bandwidth: {:.2f} MiB/s ({:.2f} MB/s)\n".format(
                            metrics['write_bw_mib_s'], metrics['write_bw_mb_s']))
                        log_file.write("Sync latency (min): {:.9f} seconds\n".format(metrics['sync_lat_ns_min'] / float(NANO_TO_SEC)))
                        log_file.write("Sync latency (avg): {:.9f} seconds\n".format(metrics['sync_lat_sec_mean']))
                        log_file.write("Sync latency (max): {:.9f} seconds\n".format(metrics['sync_lat_ns_max'] / float(NANO_TO_SEC)))
                        log_file.write("Sync latency (p99): {:.9f} seconds\n".format(metrics['sync_lat_sec_p99']))
                        log_file.write("Sync latency (stddev): {:.9f} seconds\n".format(metrics['sync_lat_ns_stddev'] / float(NANO_TO_SEC)))
                        log_file.write("Theoretical max ops/s: {:.2f}\n".format(1.0 / metrics['sync_lat_sec_mean']))
                        log_file.write("FIO runtime: {:.3f} seconds\n".format(metrics['runtime_ms'] / 1000))
                        log_file.write("\nRaw Metrics Dictionary:\n")
                        for key, value in sorted(metrics.items()):
                            log_file.write("{}: {}\n".format(key, value))
                    
                    if debug:
                        print("Debug: Metrics logged to", metrics_log_file)
                        
                except Exception as e:
                    print("Warning: Failed to log metrics:", e)
            
            print("Test completed successfully!")
            return elapsed_time, metrics
            
        except (ValueError, KeyError) as e:
            if debug:
                print("Debug: Error parsing fio JSON output:", e)
            print("Error: Failed to parse fio results:", e)
            return None, None
            
    except (subprocess.CalledProcessError, OSError) as e:
        print("Error running fio command:", e)
        return None, None
    finally:
        # Clean up the temporary job file
        try:
            os.unlink(job_file_path)
        except OSError:
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
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    distro_name = line.split("=", 1)[1].strip().strip('"')
                    break
    except:
        pass
    
    # Print OS (showing distro as the OS)
    print("OS:            " + distro_name)
    
    # Print kernel version
    print("Kernel:        " + platform.release())
    
    # CPU information
    try:
        with open("/proc/cpuinfo") as f:
            cpu_info = f.read()
        cpu_model = re.search(r"model name\s+:\s+(.*)", cpu_info)
        if cpu_model:
            print("CPU:           " + cpu_model.group(1))
    except:
        print("CPU:           " + platform.processor())
    
    # Memory information
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    mem_kb = int(line.split()[1])
                    mem_gb = mem_kb / 1024.0 / 1024.0
                    print("Memory:        {:.2f} GB".format(mem_gb))
                    break
    except:
        pass
    
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
    display_keys = ["name", "model", "vendor", "serial", "type"]
    display_keys = [k for k in display_keys if k in all_keys]
    
    # Create a format string for the table
    col_widths = {}
    for key in display_keys:
        # Get the maximum width needed for this column
        max_width = len(key)
        for device in devices:
            if key in device:
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
            row_parts.append("{0:{1}}".format(str(device.get(key, '')), col_widths[key]))
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
        description='Test fsync/fdatasync performance on storage devices using fio',
        epilog='For more information, see: https://www.percona.com/blog/fsync-performance-storage-devices/'
    )
    parser.add_argument('--sync-method', choices=['fsync', 'fdatasync'], default='fsync',
                      help='Sync method to use (fsync or fdatasync)')
    parser.add_argument('--mmap-size', type=int, default=4096,
                      help='Size of memory map in bytes (default: 4096)')
    parser.add_argument('--iterations', type=int, default=1000,
                      help='Number of iterations (default: 1000)')
    parser.add_argument('--output', default='testfile',
                      help='Output file name (default: testfile)')
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
    
    # Check if fio is available
    if not check_fio_available():
        print("Error: fio is not installed or not in PATH. Please install fio first.")
        print("Install with: sudo yum install -y fio")
        sys.exit(1)
    
    # Validate arguments
    if args.mmap_size <= 0:
        print("Error: Memory map size must be greater than 0")
        sys.exit(1)
    
    if args.iterations <= 0:
        print("Error: Number of iterations must be greater than 0")
        sys.exit(1)
    
    # Safety checks for the output file
    if not args.force and not is_safe_output_path(args.output, args.debug):
        print("\nIf you're absolutely sure you want to proceed, run again with --force")
        print("WARNING: Using --force can potentially cause system damage or data loss!")
        sys.exit(1)
    
    # Check if running as root, warn user
    if os.geteuid() == 0:
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
            except (KeyboardInterrupt, EOFError):
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
    print("Storage Sync Performance Test")
    print("="*60)
    print("Sync method:  " + sync_method)
    print("Memory size:  " + str(args.mmap_size) + " bytes")
    print("Iterations:   " + str(args.iterations))
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
        # Try direct device determination as a fallback
        try:
            output_dir = os.path.dirname(os.path.abspath(args.output))
            if not output_dir:
                output_dir = os.getcwd()
                
            # Get the device from df command directly
            cmd = ["df", "-P", output_dir]
            result = subprocess.check_output(cmd, universal_newlines=True)
            
            # Parse the output (skip header)
            lines = result.strip().split('\n')
            if len(lines) > 1:
                device_path = lines[1].split()[0]
                print("Device:       " + device_path + " (determined from path)")
                
                # Try to get device info for NVMe drives
                if 'nvme' in device_path:
                    for device in devices:
                        if device_path.endswith(device.get('name', '')):
                            model = device.get('model', '').strip()
                            if model:
                                print("Model:        " + model)
                            vendor = device.get('vendor', '').strip()
                            if vendor:
                                print("Vendor:       " + vendor)
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
            args.log_dir
        )
        
        if elapsed_time is None or metrics is None:
            print("Test failed to execute properly.")
            sys.exit(1)
        
        # Make sure elapsed_time is valid and not too small
        if elapsed_time <= 0.001:  # Less than 1 millisecond is suspiciously fast
            print("\nWarning: Test completed suspiciously quickly. Results may not be accurate.")
            # Use a reasonable default to avoid division by zero or unrealistic numbers
            elapsed_time = max(0.001, elapsed_time)
        
        # Display results
        print("\n" + "="*80)
        print("Test Results:")
        print("="*80)
        print("Total time:              {:.2f} seconds".format(elapsed_time))
        print("Operations:              {}".format(args.iterations))
        
        # FIO measured metrics - write performance
        print("Write IOPS:              {:.2f}".format(metrics['write_iops']))
        print("Bandwidth:               {:.2f} MiB/s ({:.2f} MB/s)".format(
            metrics['write_bw_mib_s'], metrics['write_bw_mb_s']))
        
        # For CentOS 7 compatibility (Python 2.7), avoid using underscores in numeric literals
        NANO_TO_SEC = 1000000000  # 1 billion nanoseconds in a second
        
        # FIO measured metrics - sync performance
        print("Sync latency (min):      {:.9f} seconds".format(metrics['sync_lat_ns_min'] / float(NANO_TO_SEC)))
        print("Sync latency (avg):      {:.9f} seconds".format(metrics['sync_lat_sec_mean']))
        print("Sync latency (max):      {:.9f} seconds".format(metrics['sync_lat_ns_max'] / float(NANO_TO_SEC)))
        print("Sync latency (p99):      {:.9f} seconds".format(metrics['sync_lat_sec_p99']))
        print("Sync latency (stddev):   {:.9f} seconds".format(metrics['sync_lat_ns_stddev'] / float(NANO_TO_SEC)))
        
        # Theoretical max operations per second based on average latency
        if metrics['sync_lat_sec_mean'] > 0:
            ops_per_sec = 1.0 / metrics['sync_lat_sec_mean']
            print("Theoretical max ops/s:   {:.2f}".format(ops_per_sec))
        
        # FIO reported runtime in milliseconds
        print("FIO runtime:             {:.3f} seconds".format(metrics['runtime_ms'] / 1000))
        
        if args.log_dir:
            print("Log directory:           {}".format(args.log_dir))
        
        print("="*80)
        
        # Cleanup if requested
        if args.cleanup:
            try:
                os.unlink(args.output)
                print("\nCleanup: Removed test file '{}'".format(args.output))
            except Exception as e:
                print("\nError during cleanup: Could not remove test file '{}': {}".format(args.output, e))
    except Exception as e:
        print("Error running test:", e)
        if args.debug:
            import traceback
            traceback.print_exc()


if __name__ == "__main__":
    main()