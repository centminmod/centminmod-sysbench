#!/usr/bin/python3
"""
fsync_fio_ext.py - Benchmark tool for testing fsync/fdatasync performance on storage devices using fio

This script tests the performance of fsync() and fdatasync() system calls on different
storage devices by repeatedly writing to a file and forcing the data to be synchronized
to disk. It can also perform random read/write mixed I/O tests with sync operations,
and YABS-style benchmarks using libaio engine.
It uses fio under the hood while maintaining the same interface as fsync.py.

Usage examples:
    # Run with default settings (fsync, 4096 bytes, 1000 iterations, sync test type)
    python fsync_fio_ext.py --non-interactive --force
    
    # Test with fdatasync instead of fsync
    python fsync_fio_ext.py --sync-method fdatasync --non-interactive --force
    
    # Test with a larger block size (1MB) for each operation
    python fsync_fio_ext.py --mmap-size 1048576 --non-interactive --force
    
    # Run a quick test with fewer iterations
    python fsync_fio_ext.py --iterations 100 --non-interactive --force
    
    # Specify a different output file
    python fsync_fio_ext.py --output /tmp/testfile --non-interactive --force
    
    # Run test on a specific device (automatically detects the device for the file)
    python fsync_fio_ext.py --output /mnt/ssd/testfile --non-interactive --force
    
    # Run with debug output
    python fsync_fio_ext.py --debug --non-interactive --force
    
    # Delete the test file after completion
    python fsync_fio_ext.py --cleanup --non-interactive --force

    # Run a random read/write mixed test (70% reads by default) with fsync on writes
    python fsync_fio_ext.py --test-type randrw --non-interactive --force
    
    # Run a random read/write mixed test with 50% reads and fdatasync on writes, file size 512M
    python fsync_fio_ext.py --test-type randrw --rwmixread 50 --sync-method fdatasync --file-size 512M --non-interactive --force
    
    # Run a YABS-style test with default parameters (2G file, libaio, 64 iodepth, 2 jobs)
    python fsync_fio_ext.py --test-type yabs --non-interactive --force
    
    # Run YABS-style test with custom block size and fdatasync
    python fsync_fio_ext.py --test-type yabs --mmap-size 65536 --sync-method fdatasync --non-interactive --force
    
    # Run YABS-style test with smaller file size
    python fsync_fio_ext.py --test-type yabs --file-size 1G --non-interactive --force

    # YABS-style 4K block test (default block size)
    python fsync_fio_ext.py --test-type yabs --mmap-size 4096 --non-interactive --force

    # YABS-style 64K block test
    python fsync_fio_ext.py --test-type yabs --mmap-size 65536 --non-interactive --force

    # YABS-style 512K block test
    python fsync_fio_ext.py --test-type yabs --mmap-size 524288 --non-interactive --force

    # YABS-style 1M block test
    python fsync_fio_ext.py --test-type yabs --mmap-size 1048576 --non-interactive --force
    
    # Combine multiple options
    python fsync_fio_ext.py --sync-method fdatasync --mmap-size 4096 --iterations 500 --non-interactive --force
"""

from __future__ import print_function  # Python 2 compatibility
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
import datetime
import threading
from contextlib import contextmanager

# Python 2/3 compatibility
PY3 = sys.version_info[0] == 3
if not PY3:
    input = raw_input

# Configuration and Constants
class Config(object):
    """Global configuration constants"""
    NANO_TO_SEC = 1000000000.0
    NANO_TO_MS = 1000000.0
    CRITICAL_DIRS = {"bin", "boot", "dev", "etc", "lib", "proc", "root", "sbin", "sys", "usr", "var"}
    ALLOWED_EXCEPTIONS = [
        (["dev", "shm"], "/dev/shm is acceptable"),
        (["var", "tmp"], "/var/tmp is acceptable"),
        (["usr", "local"], "/usr/local acceptable")
    ]
    PROGRESS_UPDATE_INTERVAL = 5.0
    MIN_RUNTIME_THRESHOLD = 0.001

class TestConfig(object):
    """Test configuration with smart defaults based on test type"""
    
    def __init__(self, test_type='sync', sync_method='fsync', mmap_size=4096, 
                 iterations=1000, file_size='1G', rwmixread=70, output='testfile.fio',
                 log_dir=None, debug=False, cleanup=False, force=False, non_interactive=False):
        self.test_type = test_type
        self.sync_method = sync_method
        self.mmap_size = mmap_size
        self.iterations = iterations
        self.file_size = file_size
        self.rwmixread = rwmixread
        self.output = output
        self.log_dir = log_dir
        self.debug = debug
        self.cleanup = cleanup
        self.force = force
        self.non_interactive = non_interactive
        
        # Apply test-type specific defaults
        if self.test_type == 'randrw':
            if self.mmap_size == 4096:  # Global default
                self.mmap_size = 16384
            if self.iterations == 1000:  # Global default
                self.iterations = 1
            if self.file_size == '1G':  # Global default
                self.file_size = '100M'
        elif self.test_type == 'yabs':
            if self.file_size == '1G':  # Global default
                # Use YABS default file size based on architecture
                arch = platform.machine().lower()
                if any(arch.startswith(arm_arch) for arm_arch in ['aarch64', 'arm', 'armv']):
                    self.file_size = '512M'
                else:
                    self.file_size = '2G'
            if self.iterations == 1000:  # Global default
                self.iterations = 1

class PerformanceError(Exception):
    """Custom exception for performance test errors"""
    pass

class SafetyError(Exception):
    """Custom exception for safety-related errors"""
    pass

# Utility Functions
def safe_subprocess_run(cmd, **kwargs):
    """Centralized subprocess execution with proper error handling"""
    try:
        # Use Popen for Python 2.7 compatibility
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
        stdout, stderr = process.communicate()
        
        # Handle text encoding for Python 2/3 compatibility
        if PY3 and isinstance(stdout, bytes):
            stdout = stdout.decode('utf-8', 'ignore')
        if PY3 and isinstance(stderr, bytes):
            stderr = stderr.decode('utf-8', 'ignore')
            
        if process.returncode != 0:
            raise PerformanceError("Command failed: {}\nError: {}".format(' '.join(cmd), stderr))
            
        # Create a simple result object
        class Result(object):
            def __init__(self, stdout, stderr, returncode):
                self.stdout = stdout
                self.stderr = stderr
                self.returncode = returncode
        
        return Result(stdout, stderr, process.returncode)
        
    except OSError:
        raise PerformanceError("Command not found: {}".format(cmd[0]))

def debug_print(message, debug=False):
    """Print debug messages only when debug mode is enabled"""
    if debug:
        print("Debug: {}".format(message))

@contextmanager
def temporary_file(suffix='.fio'):
    """Context manager for temporary file creation and cleanup"""
    temp_file = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=suffix)
    try:
        yield temp_file
    finally:
        temp_file.close()
        try:
            os.unlink(temp_file.name)
        except OSError:
            pass

# Safety and Validation
class SafetyValidator(object):
    """Handles all safety checks for file operations"""
    
    @staticmethod
    def is_safe_output_path(output_file_path, debug=False):
        """Comprehensive safety check for output file path"""
        abs_path = os.path.abspath(output_file_path)
        real_path = os.path.realpath(abs_path)
        
        debug_print("Safety check for: {} -> {}".format(output_file_path, real_path), debug)
        
        # Check for device files
        if SafetyValidator._is_device_file(real_path, debug):
            return False
            
        # Check for critical system directories
        if SafetyValidator._is_critical_directory(real_path, debug):
            return False
            
        # Verify parent directory exists
        return SafetyValidator._verify_parent_directory(abs_path)
    
    @staticmethod
    def _is_device_file(path, debug):
        """Check if path is a device file"""
        if not os.path.exists(path):
            return False
            
        try:
            mode = os.stat(path).st_mode
            if stat.S_ISBLK(mode) or stat.S_ISCHR(mode):
                print("Error: Path '{}' is a block or character device.".format(path))
                print("Writing to device files can cause severe data corruption. Aborting.")
                return True
        except OSError as e:
            debug_print("Could not stat path '{}': {}".format(path, e), debug)
        return False
    
    @staticmethod
    def _is_critical_directory(path, debug):
        """Check if path is in a critical system directory"""
        # Use os.path.normpath and split for Python 2.7 compatibility
        normalized_path = os.path.normpath(path)
        path_parts = normalized_path.split(os.sep)
        
        if len(path_parts) < 2:
            return False
            
        top_level = path_parts[1]
        if top_level not in Config.CRITICAL_DIRS:
            return False
            
        # Check allowed exceptions
        for exception_parts, reason in Config.ALLOWED_EXCEPTIONS:
            if len(path_parts) > len(exception_parts):
                if all(path_parts[i+1] == exception_parts[i] for i in range(len(exception_parts))):
                    debug_print("Path allowed: {}".format(reason), debug)
                    return False
        
        print("Error: Path '{}' is in critical system directory /{}/".format(path, top_level))
        print("Writing to system directories can cause instability. Aborting.")
        return True
    
    @staticmethod
    def _verify_parent_directory(abs_path):
        """Verify parent directory exists"""
        parent_dir = os.path.dirname(abs_path) or os.getcwd()
        if not os.path.isdir(parent_dir):
            print("Error: Parent directory '{}' does not exist.".format(parent_dir))
            return False
        return True

class ConfigValidator(object):
    """Validates test configuration parameters"""
    
    @staticmethod
    def validate(config):
        """Comprehensive configuration validation"""
        validators = {
            'mmap_size': lambda x: x > 0,
            'iterations': lambda x: x > 0,
            'rwmixread': lambda x: 0 <= x <= 100,
            'file_size': lambda x: re.match(r'^\d+[KMGTkmgt]?B?$', x) is not None
        }
        
        for field, validator in validators.items():
            value = getattr(config, field)
            if not validator(value):
                raise ValueError("Invalid {}: {}".format(field, value))
        
        # Test-specific validations
        if config.test_type not in ['sync', 'randrw', 'yabs']:
            raise ValueError("Invalid test_type: {}".format(config.test_type))
            
        if config.sync_method not in ['fsync', 'fdatasync']:
            raise ValueError("Invalid sync_method: {}".format(config.sync_method))

# System Information and Device Detection
class SystemInfo(object):
    """Handles system information gathering and display"""
    
    @staticmethod
    def print_system_info():
        """Display comprehensive system information"""
        print("\n" + "="*60)
        print("System Information")
        print("="*60)
        
        # OS Information
        distro = SystemInfo._get_distro_name()
        print("OS:            {}".format(distro))
        print("Kernel:        {}".format(platform.release()))
        
        # CPU Information
        cpu_info = SystemInfo._get_cpu_info()
        print("CPU:           {}".format(cpu_info))
        
        # Memory Information
        memory_info = SystemInfo._get_memory_info()
        print("Memory:        {}".format(memory_info))
        
        print("="*60)
    
    @staticmethod
    def _get_distro_name():
        """Get OS distribution name"""
        try:
            if os.path.exists("/etc/os-release"):
                with open("/etc/os-release") as f:
                    for line in f:
                        if line.startswith("PRETTY_NAME="):
                            return line.split("=", 1)[1].strip().strip('"')
            return platform.system()
        except Exception:
            return "Unknown"
    
    @staticmethod
    def _get_cpu_info():
        """Get CPU information"""
        try:
            if platform.system() == "Linux" and os.path.exists("/proc/cpuinfo"):
                with open("/proc/cpuinfo") as f:
                    content = f.read()
                match = re.search(r"model name\s+:\s+(.*)", content)
                if match:
                    return match.group(1).strip()
            return platform.processor() or "Unknown"
        except Exception:
            return "Unknown"
    
    @staticmethod
    def _get_memory_info():
        """Get memory information"""
        try:
            if platform.system() == "Linux" and os.path.exists("/proc/meminfo"):
                with open("/proc/meminfo") as f:
                    for line in f:
                        if line.startswith("MemTotal:"):
                            mem_kb = int(line.split()[1])
                            mem_gb = mem_kb / (1024.0 * 1024.0)
                            return "{:.2f} GB".format(mem_gb)
            return "Unknown"
        except Exception:
            return "Unknown"

class DeviceManager(object):
    """Manages storage device detection and information"""
    
    @staticmethod
    def get_storage_devices():
        """Get filtered list of storage devices"""
        try:
            result = safe_subprocess_run(["lsblk", "-d", "-o", "name,model,vendor,serial,type"])
            return DeviceManager._parse_lsblk_output(result.stdout)
        except PerformanceError:
            return []
    
    @staticmethod
    def _parse_lsblk_output(output):
        """Parse lsblk output and filter devices"""
        devices = []
        lines = output.strip().split('\n')
        
        if len(lines) <= 1:
            return devices
            
        headers = [h.lower() for h in lines[0].split()]
        
        for line in lines[1:]:
            parts = line.split(None, len(headers) - 1)
            if len(parts) >= len(headers):
                device = {headers[i]: parts[i] for i in range(len(headers))}
                if DeviceManager._should_include_device(device):
                    devices.append(device)
        
        return devices
    
    @staticmethod
    def _should_include_device(device):
        """Determine if device should be included in results"""
        name = device.get('name', '').lower()
        device_type = device.get('type', '').lower()
        model = device.get('model', '').lower()
        
        # Filter out non-storage devices
        excluded_patterns = ['sr', 'fd', 'loop', 'ram']
        excluded_types = ['rom', 'loop']
        excluded_models = ['floppy', 'cdrom', 'virtual']
        
        return not (
            any(name.startswith(pattern) for pattern in excluded_patterns) or
            device_type in excluded_types or
            any(pattern in model for pattern in excluded_models)
        )
    
    @staticmethod
    def get_device_for_path(path, devices, debug=False):
        """Determine storage device for given file path"""
        try:
            abs_path = os.path.abspath(path)
            if not os.path.exists(abs_path):
                abs_path = os.path.dirname(abs_path)
                
            result = safe_subprocess_run(["df", "-P", abs_path])
            device_path = result.stdout.split('\n')[1].split()[0]
            
            debug_print("Device path from df: {}".format(device_path), debug)
            
            # Extract device name
            match = re.search(r'/dev/([a-zA-Z0-9]+)', device_path)
            if match:
                device_name = match.group(1)
                for device in devices:
                    if device.get('name') == device_name:
                        return device
            
            return {"name": device_path, "raw_path": True}
            
        except Exception as e:
            debug_print("Error determining device for path: {}".format(e), debug)
            return None
    
    @staticmethod
    def print_storage_devices(devices):
        """Display formatted storage device information"""
        print("\n" + "="*60)
        print("Storage Devices")
        print("="*60)
        
        if not devices:
            print("No storage devices detected.")
            print("="*60)
            return
        
        # Determine column widths
        display_keys = ["name", "model", "vendor", "serial", "type"]
        col_widths = {}
        
        for key in display_keys:
            max_width = len(key)
            for device in devices:
                value = str(device.get(key, ''))
                max_width = max(max_width, len(value))
            col_widths[key] = max_width
        
        # Print header
        header_parts = []
        for key in display_keys:
            header_parts.append("{0:{1}}".format(key.upper(), col_widths[key]))
        header = "  ".join(header_parts)
        print(header)
        print("-" * len(header))
        
        # Print devices
        for device in devices:
            row_parts = []
            for key in display_keys:
                value = device.get(key, '')
                row_parts.append("{0:{1}}".format(str(value), col_widths[key]))
            row = "  ".join(row_parts)
            print(row)
        
        print("="*60)

# FIO Integration
class FioJobGenerator(object):
    """Generates FIO job configurations"""
    
    TEMPLATES = {
        'sync': """
[global]
direct=1
ioengine=sync
iodepth=1
numjobs=1
group_reporting
filename={output_file}
size={mmap_size}
loops={iterations}
time_based=0
sync=1

[{job_name}]
rw=write
bs={mmap_size}
{sync_method}=1
write_bw_log={job_name}_bw.log
write_lat_log={job_name}_lat.log
write_iops_log={job_name}_iops.log
log_avg_msec=1000
""",
        'randrw': """
[global]
direct=1
ioengine=sync
iodepth=1
numjobs=1
group_reporting
filename={output_file}
size={file_size}
bs={mmap_size}
loops={iterations}
time_based=0
sync=1

[{job_name}]
rw=randrw
rwmixread={rwmixread}
{sync_method}=1
write_bw_log={job_name}_write_bw.log
write_lat_log={job_name}_write_lat.log
write_iops_log={job_name}_write_iops.log
log_avg_msec=1000
""",
        'yabs': """
[global]
direct=1
ioengine=libaio
iodepth=64
numjobs=2
group_reporting
filename={output_file}
size={file_size}
runtime=30
time_based=0
gtod_reduce=1

[{job_name}]
rw=randrw
rwmixread=50
bs={mmap_size}
{sync_method}=1
write_bw_log={job_name}_bw.log
write_lat_log={job_name}_lat.log
write_iops_log={job_name}_iops.log
log_avg_msec=1000
"""
    }
    
    @staticmethod
    def generate_job(config):
        """Generate FIO job configuration based on test config"""
        job_name = "{}_{}_{}_test".format(config.test_type, config.sync_method, int(time.time()))
        template = FioJobGenerator.TEMPLATES[config.test_type]
        
        return template.format(
            job_name=job_name,
            sync_method=config.sync_method,
            output_file=config.output,
            mmap_size=config.mmap_size,
            iterations=config.iterations,
            file_size=config.file_size,
            rwmixread=config.rwmixread
        )

class FioResultsParser(object):
    """Parses and processes FIO JSON output"""
    
    def __init__(self, fio_output):
        self.data = json.loads(fio_output)
        self.job_data = self.data['jobs'][0]
        self.metrics = {}
    
    def parse_all_metrics(self):
        """Parse all available metrics from FIO output"""
        self._parse_runtime_metrics()
        self._parse_sync_metrics()
        self._parse_io_metrics('write')
        self._parse_io_metrics('read')
        return self.metrics
    
    def _parse_runtime_metrics(self):
        """Parse job runtime information"""
        self.metrics['job_runtime_ms'] = self.job_data.get('elapsed', 0) * 1000
    
    def _parse_sync_metrics(self):
        """Parse synchronization performance metrics"""
        sync_stats = self.job_data.get('sync')
        if not sync_stats:
            return
            
        # Handle different FIO versions
        if 'lat_ns' in sync_stats:
            lat_data = sync_stats['lat_ns']
            multiplier = 1
        else:
            lat_data = sync_stats
            multiplier = 1000  # Convert from usec to nsec
        
        self.metrics.update({
            'sync_lat_ns_min': lat_data.get('min', 0) * multiplier,
            'sync_lat_ns_max': lat_data.get('max', 0) * multiplier,
            'sync_lat_ns_mean': lat_data.get('mean', 0) * multiplier,
            'sync_lat_ns_stddev': lat_data.get('stddev', 0) * multiplier,
        })
        
        # Parse percentiles
        percentiles = lat_data.get('percentile', {})
        self.metrics.update({
            'sync_lat_ns_p1': percentiles.get('1.000000', 0) * multiplier,
            'sync_lat_ns_p50': percentiles.get('50.000000', 0) * multiplier,
            'sync_lat_ns_p99': percentiles.get('99.000000', 0) * multiplier,
        })
        
        # Calculate derived metrics
        mean_ns = self.metrics['sync_lat_ns_mean']
        p99_ns = self.metrics['sync_lat_ns_p99']
        self.metrics.update({
            'sync_lat_sec_mean': mean_ns / Config.NANO_TO_SEC if mean_ns else 0,
            'sync_lat_sec_p99': p99_ns / Config.NANO_TO_SEC if p99_ns else 0,
        })
    
    def _parse_io_metrics(self, operation):
        """Parse I/O metrics for read or write operations"""
        op_data = self.job_data.get(operation)
        if not op_data:
            return
            
        bw_bytes = op_data.get('bw_bytes', op_data.get('bw', 0) * 1024)
        
        self.metrics.update({
            '{}_iops'.format(operation): op_data.get('iops', 0),
            '{}_bw_kibytes'.format(operation): op_data.get('bw', 0),
            '{}_bw_bytes'.format(operation): bw_bytes,
            '{}_bw_mib_s'.format(operation): bw_bytes / (1024.0 * 1024.0),
            '{}_bw_mb_s'.format(operation): bw_bytes / (1000.0 * 1000.0),
            '{}_lat_ns_mean'.format(operation): op_data.get('lat_ns', {}).get('mean', -1),
        })

class FioRunner(object):
    """Handles FIO execution and monitoring"""
    
    def __init__(self, config):
        self.config = config
    
    def run_test(self):
        """Execute FIO test and return results"""
        if not self._check_fio_available():
            raise PerformanceError("fio is not installed or not in PATH")
        
        job_content = FioJobGenerator.generate_job(self.config)
        
        with temporary_file('.fio') as job_file:
            job_file.write(job_content)
            job_file.flush()
            
            debug_print("FIO job content:\n{}".format(job_content), self.config.debug)
            
            return self._execute_fio(job_file.name)
    
    def _check_fio_available(self):
        """Check if fio command is available"""
        try:
            safe_subprocess_run(["fio", "--version"])
            return True
        except PerformanceError:
            return False
    
    def _execute_fio(self, job_file_path):
        """Execute FIO and parse results"""
        start_time = time.time()
        
        cmd = ["fio", job_file_path, "--output-format=json"]
        debug_print("Running: {}".format(' '.join(cmd)), self.config.debug)
        
        print("Running {} test (sync method: {}, ops: {})...".format(
            self.config.test_type, self.config.sync_method, self.config.iterations))
        
        try:
            result = safe_subprocess_run(cmd)
            elapsed_time = time.time() - start_time
            
            # Log raw output if requested
            if self.config.log_dir:
                self._log_output(result.stdout)
            
            # Parse results
            parser = FioResultsParser(result.stdout)
            metrics = parser.parse_all_metrics()
            
            # Log parsed metrics if requested
            if self.config.log_dir:
                self._log_metrics(metrics, elapsed_time)
            
            print("Test completed successfully!")
            return elapsed_time, metrics
            
        except PerformanceError as e:
            raise PerformanceError("FIO execution failed: {}".format(e))
    
    def _log_output(self, output):
        """Log raw FIO output to file"""
        try:
            if not os.path.exists(self.config.log_dir):
                os.makedirs(self.config.log_dir)
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            log_file = os.path.join(
                self.config.log_dir,
                "fio_raw_{}_{}_{}_{}.json".format(
                    self.config.test_type, self.config.sync_method, timestamp, int(time.time()))
            )
            
            with open(log_file, 'w') as f:
                f.write(output)
                
            debug_print("Raw output logged to {}".format(log_file), self.config.debug)
            
        except Exception as e:
            print("Warning: Failed to log FIO output: {}".format(e))
    
    def _log_metrics(self, metrics, elapsed_time):
        """Log parsed metrics to file"""
        try:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            log_file = os.path.join(
                self.config.log_dir,
                "fio_metrics_{}_{}_{}_{}.txt".format(
                    self.config.test_type, self.config.sync_method, timestamp, int(time.time()))
            )
            
            with open(log_file, 'w') as f:
                f.write("FIO Metrics Summary ({}, {}):\n".format(
                    self.config.test_type, self.config.sync_method))
                f.write("=" * 50 + "\n")
                f.write("Total script time: {:.2f} seconds\n".format(elapsed_time))
                f.write("Operations: {}\n".format(self.config.iterations))
                f.write("Block size: {} bytes\n".format(self.config.mmap_size))
                
                if self.config.test_type in ['randrw', 'yabs']:
                    f.write("File size: {}\n".format(self.config.file_size))
                    if self.config.test_type == 'randrw':
                        f.write("Read mix: {}%\n".format(self.config.rwmixread))
                    else:  # yabs
                        f.write("Read mix: 50% (YABS standard)\n")
                        f.write("IO Engine: libaio (YABS standard)\n")
                        f.write("IO Depth: 64 (YABS standard)\n")
                        f.write("Num Jobs: 2 (YABS standard)\n")
                
                f.write("\nRaw Metrics:\n")
                for key in sorted(metrics.keys()):
                    f.write("{}: {}\n".format(key, metrics[key]))
            
            debug_print("Metrics logged to {}".format(log_file), self.config.debug)
            
        except Exception as e:
            print("Warning: Failed to log metrics: {}".format(e))

# Results Display
class ResultsDisplay(object):
    """Handles formatting and display of test results"""
    
    @staticmethod
    def display_results(config, elapsed_time, metrics):
        """Display comprehensive test results"""
        print("\n" + "="*80)
        print("Test Results ({}, {}):".format(config.test_type, config.sync_method))
        print("="*80)
        print("Total script time:       {:.2f} seconds".format(elapsed_time))
        print("Operations requested:    {}".format(config.iterations))
        
        # Write performance
        if 'write_iops' in metrics:
            ResultsDisplay._display_write_performance(metrics)
        
        # Read performance
        if 'read_iops' in metrics:
            ResultsDisplay._display_read_performance(metrics)
        
        # Sync performance
        if 'sync_lat_sec_mean' in metrics:
            ResultsDisplay._display_sync_performance(metrics)
        
        print("\nFIO job runtime:         {:.3f} seconds".format(
           metrics.get('job_runtime_ms', 0) / 1000))
       
        if config.log_dir:
           print("Log directory:           {}".format(config.log_dir))
       
        print("="*80)
   
    @staticmethod
    def _display_write_performance(metrics):
        """Display write performance metrics"""
        print("\n--- Write Performance ---")
        print("Write IOPS:              {:.2f}".format(metrics.get('write_iops', 0)))
        print("Write Bandwidth:         {:.2f} MiB/s ({:.2f} MB/s)".format(
            metrics.get('write_bw_mib_s', 0), metrics.get('write_bw_mb_s', 0)))
        
        write_lat = metrics.get('write_lat_ns_mean', -1)
        if write_lat != -1:
            print("Write Latency (avg):     {:.3f} ms".format(write_lat / Config.NANO_TO_MS))
    
    @staticmethod
    def _display_read_performance(metrics):
        """Display read performance metrics"""
        print("\n--- Read Performance ---")
        print("Read IOPS:               {:.2f}".format(metrics.get('read_iops', 0)))
        print("Read Bandwidth:          {:.2f} MiB/s ({:.2f} MB/s)".format(
            metrics.get('read_bw_mib_s', 0), metrics.get('read_bw_mb_s', 0)))
        
        read_lat = metrics.get('read_lat_ns_mean', -1)
        if read_lat != -1:
            print("Read Latency (avg):      {:.3f} ms".format(read_lat / Config.NANO_TO_MS))
    
    @staticmethod
    def _display_sync_performance(metrics):
        """Display sync performance metrics"""
        print("\n--- Sync Performance (for writes) ---")
        print("Sync latency (min):      {:.9f} seconds".format(
            metrics.get('sync_lat_ns_min', 0) / Config.NANO_TO_SEC))
        print("Sync latency (avg):      {:.9f} seconds".format(
            metrics.get('sync_lat_sec_mean', 0)))
        print("Sync latency (max):      {:.9f} seconds".format(
            metrics.get('sync_lat_ns_max', 0) / Config.NANO_TO_SEC))
        print("Sync latency (p99):      {:.9f} seconds".format(
            metrics.get('sync_lat_sec_p99', 0)))
        print("Sync latency (stddev):   {:.9f} seconds".format(
            metrics.get('sync_lat_ns_stddev', 0) / Config.NANO_TO_SEC))
        
        sync_mean = metrics.get('sync_lat_sec_mean', 0)
        if sync_mean > 0:
            ops_per_sec = 1.0 / sync_mean
            print("Theoretical max sync ops/s: {:.2f} (based on avg sync latency)".format(ops_per_sec)) 

# Main Application
class PerformanceTestApp(object):
    """Main application class orchestrating the performance test"""
    
    def __init__(self):
        self.config = None
    
    def run(self):
        """Main application entry point"""
        try:
            self.config = self._parse_arguments()
            self._validate_environment()
            self._validate_safety()
            self._display_system_info()
            self._run_performance_test()
            self._cleanup_if_requested()
            
        except (PerformanceError, SafetyError, ValueError) as e:
            print("Error: {}".format(e))
            sys.exit(1)
        except KeyboardInterrupt:
            print("\nTest interrupted by user.")
            sys.exit(1)
        except Exception as e:
            print("Unexpected error: {}".format(e))
            if self.config and self.config.debug:
                import traceback
                traceback.print_exc()
            sys.exit(1)
    
    def _parse_arguments(self):
        """Parse command line arguments into TestConfig"""
        parser = argparse.ArgumentParser(
            description='Test fsync/fdatasync performance or random R/W mix performance using fio',
            epilog='Enhanced production-ready version with improved error handling and maintainability'
        )
        
        parser.add_argument('--test-type', choices=['sync', 'randrw', 'yabs'], default='sync',
                          help='Test type: "sync" for sequential write+sync, "randrw" for random R/W mix, "yabs" for YABS-style test')
        parser.add_argument('--sync-method', choices=['fsync', 'fdatasync'], default='fsync',
                          help='Sync method for writes (default: fsync)')
        parser.add_argument('--mmap-size', type=int, default=4096,
                          help='I/O operation size in bytes (default: 4096)')
        parser.add_argument('--iterations', type=int, default=1000,
                          help='Number of I/O operations (default: 1000)')
        parser.add_argument('--output', default='testfile.fio',
                          help='Output file name (default: testfile.fio)')
        parser.add_argument('--file-size', default='1G',
                          help='Total file size for test (default: 1G)')
        parser.add_argument('--rwmixread', type=int, default=70,
                          help='Read percentage for randrw test (default: 70)')
        parser.add_argument('--log-dir', help='Directory for log files (default: disabled)')
        parser.add_argument('--debug', action='store_true', help='Enable debug output')
        parser.add_argument('--cleanup', action='store_true', help='Delete test file after completion')
        parser.add_argument('--force', action='store_true', help='Bypass safety checks (DANGEROUS)')
        parser.add_argument('--non-interactive', action='store_true', help='Skip prompts for scripting')
        
        args = parser.parse_args()
        
        # Convert args to config object
        config = TestConfig(
            test_type=args.test_type,
            sync_method=args.sync_method,
            mmap_size=args.mmap_size,
            iterations=args.iterations,
            file_size=args.file_size,
            rwmixread=args.rwmixread,
            output=args.output,
            log_dir=args.log_dir,
            debug=args.debug,
            cleanup=args.cleanup,
            force=args.force,
            non_interactive=args.non_interactive
        )
        
        ConfigValidator.validate(config)
        return config
    
    def _validate_environment(self):
        """Validate execution environment"""
        # Check for root privileges
        if hasattr(os, 'geteuid') and os.geteuid() == 0:
            self._handle_root_warning()
    
    def _handle_root_warning(self):
        """Handle root user warning and confirmation"""
        print("-" * 60)
        print("WARNING: This script is running as root!")
        print("Please verify the output path is correct:")
        print("  Output file: {}".format(os.path.abspath(self.config.output)))
        print("Incorrect paths can cause severe data loss or system damage.")
        
        if not self.config.force and not self.config.non_interactive:
            try:
                confirm = input("Type 'yes' to proceed if you are sure: ")
                if confirm.lower() != 'yes':
                    raise SafetyError("User aborted due to root privileges")
            except (KeyboardInterrupt, EOFError):
                raise SafetyError("User aborted due to root privileges")
        print("-" * 60)
    
    def _validate_safety(self):
        """Validate output path safety"""
        if not self.config.force:
            if not SafetyValidator.is_safe_output_path(self.config.output, self.config.debug):
                raise SafetyError(
                    "Unsafe output path detected. Use --force to override (DANGEROUS)"
                )
    
    def _display_system_info(self):
        """Display system and device information"""
        SystemInfo.print_system_info()
        
        devices = DeviceManager.get_storage_devices()
        DeviceManager.print_storage_devices(devices)
        
        # Display test device information
        test_device = DeviceManager.get_device_for_path(
            self.config.output, devices, self.config.debug
        )
        self._display_test_info(test_device)
    
    def _display_test_info(self, test_device):
        """Display test configuration information"""
        print("\n" + "="*60)
        print("FIO Storage Performance Test")
        print("="*60)
        print("Test Type:    {}".format(self.config.test_type))
        print("Sync method:  {} (for writes)".format(self.config.sync_method))
        print("Op size:      {} bytes (fio bs)".format(self.config.mmap_size))
        
        if self.config.test_type == 'sync':
            print("Operations:   {} (fio loops)".format(self.config.iterations))
        elif self.config.test_type == 'randrw':
            print("Operations:   {} (fio loops)".format(self.config.iterations))
            print("File size:    {} (fio size)".format(self.config.file_size))
            print("Read mix %:   {}".format(self.config.rwmixread))
        elif self.config.test_type == 'yabs':
            print("File size:    {} (fio size)".format(self.config.file_size))
            print("Read mix %:   50 (YABS standard)")
            print("IO Engine:    libaio (YABS standard)")
            print("IO Depth:     64 (YABS standard)")
            print("Num Jobs:     2 (YABS standard)")
            print("Runtime:      30 seconds (YABS standard)")
        
        print("Output file:  {}".format(self.config.output))
        
        if test_device:
            self._display_device_info(test_device)
        else:
            print("Device:       Unknown (unable to determine storage device)")
        
        print("="*60 + "\n")
    
    def _display_device_info(self, device):
        """Display device-specific information"""
        if device.get('raw_path', False):
            print("Device:       {} (determined from path)".format(device.get('name', 'unknown')))
        else:
            print("Device:       /dev/{}".format(device.get('name', 'unknown')))
            
            model = device.get('model', '').strip()
            if model:
                print("Model:        {}".format(model))
                
            vendor = device.get('vendor', '').strip()
            if vendor:
                print("Vendor:       {}".format(vendor))
    
    def _run_performance_test(self):
        """Execute the performance test"""
        runner = FioRunner(self.config)
        elapsed_time, metrics = runner.run_test()
        
        # Validate results
        if elapsed_time <= Config.MIN_RUNTIME_THRESHOLD:
            print("\nWarning: Test completed very quickly ({:.3f}s). "
                  "Results may not reflect sustained performance.".format(elapsed_time))
            elapsed_time = max(Config.MIN_RUNTIME_THRESHOLD, elapsed_time)
        
        # Display results
        ResultsDisplay.display_results(self.config, elapsed_time, metrics)
    
    def _cleanup_if_requested(self):
        """Clean up test files if requested"""
        if self.config.cleanup:
            try:
                if os.path.exists(self.config.output):
                    os.unlink(self.config.output)
                    print("\nCleanup: Removed test file '{}'".format(self.config.output))
                else:
                    debug_print("Test file '{}' not found for removal".format(self.config.output), 
                              self.config.debug)
            except Exception as e:
                print("\nError during cleanup: Could not remove test file '{}': {}".format(
                    self.config.output, e))

def main():
    """Application entry point"""
    app = PerformanceTestApp()
    app.run()

if __name__ == "__main__":
    main()