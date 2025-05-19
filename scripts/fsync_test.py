#!/usr/bin/python
"""
fsync_test.py - Benchmark tool for testing fsync/fdatasync performance on storage devices

This script tests the performance of fsync() and fdatasync() system calls on different
storage devices by repeatedly writing to a file and forcing the data to be synchronized
to disk. It helps identify the I/O characteristics and performance of storage systems.

Based on the original script from Percona's blog post:
https://www.percona.com/blog/fsync-performance-storage-devices/

Usage examples:
    # Run with default settings (fsync, 512 bytes, 1000 iterations)
    python fsync_test.py
    
    # Test with fdatasync instead of fsync
    python fsync_test.py --sync-method fdatasync
    
    # Test with a larger memory map size (1MB)
    python fsync_test.py --mmap-size 1048576
    
    # Run a quick test with fewer iterations
    python fsync_test.py --iterations 100
    
    # Specify a different output file
    python fsync_test.py --output /tmp/testfile
    
    # Combine multiple options
    python fsync_test.py --sync-method fdatasync --mmap-size 4096 --iterations 500
    
    # Run test on a specific device (automatically detects the device for the file)
    python fsync_test.py --output /mnt/ssd/testfile
"""

from __future__ import print_function  # For Python 2 compatibility
import os
import sys
import mmap
import argparse
import time
import subprocess
import re
import platform

# Detect Python version
PY3 = sys.version_info[0] == 3
if not PY3:
    input = raw_input


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
    except Exception as e:
        if debug:
            print("Debug: Error determining storage device for path:", e)
        else:
            print("Warning: Error determining storage device for path:", e)
    
    return None


def run_sync_test(sync_method_func, output_file, mmap_size, iterations):
    """
    Run the actual synchronization test with the specified parameters.
    
    Args:
        sync_method_func (function): Function to use for synchronization (os.fsync or os.fdatasync)
        output_file (str): Path to the file to write to
        mmap_size (int): Size of the memory map in bytes
        iterations (int): Number of write and sync operations to perform
    
    Returns:
        float: Elapsed time in seconds
    """
    # Open a file with direct I/O to bypass the kernel page cache
    # O_DIRECT ensures data is written directly to the physical device
    try:
        fd = os.open(output_file, os.O_RDWR|os.O_CREAT|os.O_DIRECT)
    except OSError as e:
        print("Error opening file:", e)
        print("Note: O_DIRECT may not be supported on all file systems or platforms")
        sys.exit(1)
    
    # Create an anonymous memory-mapped file of the specified size
    # Using -1 creates a map not associated with any specific file descriptor
    m = mmap.mmap(-1, mmap_size)
    
    start_time = time.time()
    
    try:
        # Run the test for the specified number of iterations
        for i in range(1, iterations + 1):
            # Reset file position to beginning
            os.lseek(fd, 0, os.SEEK_SET)
            
            # Modify a byte in the memory map
            # Python 2.7 and Python 3 handle mmap assignments differently
            if PY3:
                # Python 3: Use integer value (49 = ASCII '1')
                m[1] = 49
            else:
                # Python 2: Use a single-character string '1'
                m[1] = '1'
            
            # Write the memory map to the file
            os.write(fd, m)
            
            # Force synchronization to disk using the specified method
            sync_method_func(fd)
            
            # Print progress every 100 iterations
            if i % 100 == 0 or i == iterations:
                print("Completed {0}/{1} iterations ({2:.1f}%)".format(
                    i, iterations, i/float(iterations)*100))
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
    except Exception as e:
        print("\nError during test:", e)
        # Don't return here, let the elapsed_time calculation happen
    finally:
        # Close the file descriptor to release resources
        os.close(fd)
    
    elapsed_time = time.time() - start_time
    return elapsed_time


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
        description='Test fsync/fdatasync performance on storage devices',
        epilog='For more information, see: https://www.percona.com/blog/fsync-performance-storage-devices/'
    )
    parser.add_argument('--sync-method', choices=['fsync', 'fdatasync'], default='fsync',
                      help='Sync method to use (fsync or fdatasync)')
    parser.add_argument('--mmap-size', type=int, default=512,
                      help='Size of memory map in bytes (default: 512)')
    parser.add_argument('--iterations', type=int, default=1000,
                      help='Number of iterations (default: 1000)')
    parser.add_argument('--output', default='testfile',
                      help='Output file name (default: testfile)')
    parser.add_argument('--debug', action='store_true',
                      help='Enable debug output')
    args = parser.parse_args()
    
    # Validate arguments
    if args.mmap_size <= 0:
        print("Error: Memory map size must be greater than 0")
        sys.exit(1)
    
    if args.iterations <= 0:
        print("Error: Number of iterations must be greater than 0")
        sys.exit(1)
    
    # Print system information
    print_system_info()
    
    # Get and display storage devices
    devices = get_storage_devices()
    print_storage_devices(devices)
    
    # Determine which device will be used for the test
    test_device = get_device_for_path(args.output, devices, args.debug)
    
    # Choose the appropriate sync method
    # fsync: Synchronizes both file data and metadata (inode) to disk
    # fdatasync: Synchronizes only the file data to disk, not metadata
    sync_method = os.fsync if args.sync_method == 'fsync' else os.fdatasync
    sync_method_name = args.sync_method
    
    print("\n" + "="*60)
    print("Storage Sync Performance Test")
    print("="*60)
    print("Sync method:  " + sync_method_name)
    print("Memory size:  " + str(args.mmap_size) + " bytes")
    print("Iterations:   " + str(args.iterations))
    print("Output file:  " + args.output)
    
    if test_device:
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
        elapsed_time = run_sync_test(sync_method, args.output, args.mmap_size, args.iterations)
        
        # Make sure elapsed_time is valid and not too small
        if elapsed_time <= 0.001:  # Less than 1 millisecond is suspiciously fast
            print("\nWarning: Test completed suspiciously quickly. Results may not be accurate.")
            # Use a reasonable default to avoid division by zero or unrealistic numbers
            elapsed_time = max(0.001, elapsed_time)
        
        # Calculate and display results
        print("\n" + "="*60)
        print("Test Results:")
        print("="*60)
        print("Total time:        {:.2f} seconds".format(elapsed_time))
        print("Operations:        {}".format(args.iterations))
        op_per_sec = args.iterations / float(elapsed_time)
        print("Operations/sec:    {:.2f}".format(op_per_sec))
        avg_ms = (elapsed_time * 1000) / float(args.iterations)
        print("Avg time per op:   {:.3f} ms".format(avg_ms))
        print("="*60)
    except Exception as e:
        print("Error running test:", e)


if __name__ == "__main__":
    main()
