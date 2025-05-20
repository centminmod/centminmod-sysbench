## 💾 Why Drive `fsync()` Performance Matters

When applications save data, they often rely on a system call called `fsync()` to ensure that data is physically written to the storage device. This is crucial for data integrity, especially in databases where losing recent transactions can be catastrophic.

**Key Points:**

* **Data Durability:** `fsync()` ensures that data is safely stored on disk, protecting against data loss during unexpected events like power failures.

* **Performance Impact:** The speed of `fsync()` operations varies across storage devices. Traditional hard drives (HDDs) have slower `fsync()` times compared to solid-state drives (SSDs), affecting how quickly applications can confirm data is saved.

* **Database Operations:** In databases like MySQL, `fsync()` is used to write transaction logs and data files. Slow `fsync()` performance can lead to increased latency for transactions, affecting overall database responsiveness.

* **Storage Choices:** Choosing storage with better `fsync()` performance (like enterprise-grade SSDs) can significantly improve application and database performance.

Understanding and optimizing `fsync()` performance is essential for building reliable and efficient systems.

## Examples

Example results for [fsync_fio.py](https://github.com/centminmod/centminmod-sysbench/blob/master/scripts/fsync_fio.py) (alternative to [sysbench fsync benchmark test using FIO tool](https://github.com/centminmod/centminmod-sysbench/tree/master#sysbench-fileio-fsync)) to test various dedicated servers' drives and their fsync performance as outlined at https://www.percona.com/blog/fsync-performance-storage-devices/. You can see that datacenter or enterprise NVMe/SATA SSD have much faster fsync performance than regularly consumer SATA SSD or consumer NVMe drives.

For `4096 bytes` fsync test:

| Server # | CPU | OS | Kernel | Storage | IOPS | Sync latency (avg) (seconds) |
|----------|-----|-------|--------|---------|---------------|----------------------|
| [1](#dedicated-server-1) | Intel Xeon E-2276G | AlmaLinux 8.10 | 4.18.0-425.19.2.el8_7.x86_64 | 2x 960GB NVMe RAID 1 (Samsung PM983 + Kingston DC1500M) | 27,027.03 | 0.000003488 |
| [2](#dedicated-server-2) | Intel Core i7-4790K | AlmaLinux 9.5 | 5.14.0-284.11.1.el9_2.x86_64 | 240GB Samsung PM863 SATA SSD | 13,333.33 | 0.000012822 |
| [4](#dedicated-server-4) | Intel Xeon E3-1270 v6 | Rocky Linux 9.5 | 5.14.0-503.14.1.el9_5.x86_64 | 2x 450GB Intel DC P3520 NVMe RAID 1 | 1,897.53 | 0.000004161 |
| [7a](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 2x 960GB Kingston DC600M SATA SSD raid 1 | 1,362.40 | 0.000194993 |
| [7b](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 1TB Kingston KC3000 NVMe Raid 10 | 819.67 | 0.000126701 |
| [7c](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 960GB Kingston DC600M SATA SSD Raid 10 | 766.28 | 0.000360230 |
| [6](#dedicated-server-6) | AMD EPYC 7452 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 2x 2TB Kingston KC3000 NVMe RAID 1 | 758.73 | 0.000120319 |
| [5](#dedicated-server-5) | Intel Xeon E-2236 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 512GB Kingston KC3000 NVMe | 701.26 | 0.000128123 |
| [3](#dedicated-server-3) | AMD Ryzen 9 5950X | AlmaLinux 9.5 | 5.14.0-503.16.1.el9_5.x86_64 | 512GB Samsung 850 Pro SATA SSD | 390.78 | 0.000050542 |

For `16384 bytes` fsync test:

| Server # | CPU | OS | Kernel | Storage | IOPS | Sync latency (avg) (seconds) |
|----------|-----|-------|--------|---------|---------------|----------------------|
| [1](#dedicated-server-1) | Intel Xeon E-2276G | AlmaLinux 8.10 | 4.18.0-425.19.2.el8_7.x86_64 | 2x 960GB NVMe RAID 1 (Samsung PM983 + Kingston DC1500M) | 21,739.13 | 0.000003449 |
| [2](#dedicated-server-2) | Intel Core i7-4790K | AlmaLinux 9.5 | 5.14.0-284.11.1.el9_2.x86_64 | 240GB Samsung PM863 SATA SSD | 9,259.26 | 0.000015483 |
| [4](#dedicated-server-4) | Intel Xeon E3-1270 v6 | Rocky Linux 9.5 | 5.14.0-503.14.1.el9_5.x86_64 | 2x 450GB Intel DC P3520 NVMe RAID 1 | 1,782.53 | 0.000004112 |
| [7a](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 2x 960GB Kingston DC600M SATA SSD raid 1 | 1,246.88 | 0.000196847 |
| [7b](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 1TB Kingston KC3000 NVMe Raid 10 | 815.00 | 0.000126493 |
| [6](#dedicated-server-6) | AMD EPYC 7452 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 2x 2TB Kingston KC3000 NVMe RAID 1 | 780.64 | 0.000116798 |
| [7c](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 960GB Kingston DC600M SATA SSD Raid 10 | 742.39 | 0.000362114 |
| [5](#dedicated-server-5) | Intel Xeon E-2236 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 512GB Kingston KC3000 NVMe | 703.23 | 0.000129106 |
| [3](#dedicated-server-3) | AMD Ryzen 9 5950X | AlmaLinux 9.5 | 5.14.0-503.16.1.el9_5.x86_64 | 512GB Samsung 850 Pro SATA SSD | 330.80 | 0.000052424 |

### Dedicated Server 1

Intel Xeon E-2276G 6C/12T, 32GB memory and 2x 960GB NVMe raid 1:

2x mismatched 960GB NVMe drives in raid 1 so take note of that for the potential peak read and write performance of the resulting benchmarks:

* Samsung SSD PM983 960GB 2.5 U.2 Gen 3.0 x4 PCIe NVMe
  * Up to 3,000MB/s Read, 1,050MB/s Write
  * 4K random read/write 400,000/40,000 IOPS
  * 1366 TBW / 1.3 DWPD
  * Power: 4 Watt (idle) 8.6 Watt (read) 8.1 Watt (write)
* Kingston DC1500M U.2 Enterprise SSD Gen 3.0 x4 PCIe NVME
  * Up to 3,100MB/s Read, 1,700MB/s Write
  * Steady-state 4k read/write 440,000/150,000 IOPS
  * 1681 TBW (1 DWPD/5yrs) (1.6 DWPD/3yrs)
  * Power: Idle: 6.30W Average read: 6.21W Average write: 11.40W Max read: 6.60W Max write: 12.24W

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 8.10 (Cerulean Leopard)
Kernel:        4.18.0-425.19.2.el8_7.x86_64
CPU:           Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Memory:        31.07 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR              SERIAL            TYPE
-------------------------------------------------------------
nvme1n1  KINGSTON  SEDC1500M960G       50026B7282926537  disk
nvme0n1  SAMSUNG   MZQLB960HAJR-00007  S437NA0N401292    disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md1 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.04 seconds
Operations:              1000
Write IOPS:              27027.03
Bandwidth:               105.57 MiB/s (110.70 MB/s)
Sync latency (min):      0.000003004 seconds
Sync latency (avg):      0.000003488 seconds
Sync latency (max):      0.000029141 seconds
Sync latency (p99):      0.000007392 seconds
Sync latency (stddev):   0.000001642 seconds
Theoretical max ops/s:   286668.82
FIO runtime:             0.001 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 8.10 (Cerulean Leopard)
Kernel:        4.18.0-425.19.2.el8_7.x86_64
CPU:           Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Memory:        31.07 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR              SERIAL            TYPE
-------------------------------------------------------------
nvme1n1  KINGSTON  SEDC1500M960G       50026B7282926537  disk
nvme0n1  SAMSUNG   MZQLB960HAJR-00007  S437NA0N401292    disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md1 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.03 seconds
Operations:              1000
Write IOPS:              21739.13
Bandwidth:               339.67 MiB/s (356.17 MB/s)
Sync latency (min):      0.000003042 seconds
Sync latency (avg):      0.000003449 seconds
Sync latency (max):      0.000030692 seconds
Sync latency (p99):      0.000004832 seconds
Sync latency (stddev):   0.000001194 seconds
Theoretical max ops/s:   289957.21
FIO runtime:             0.001 seconds
================================================================================
```

### Dedicated Server 2

OVH Intel Core i7-4790K, 32GB, 240GB SATA SSD (Samsung PM863 Datacenter Grade SATA SSD)

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-284.11.1.el9_2.x86_64
CPU:           Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz
Memory:        31.23 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL    VENDOR              SERIAL  TYPE               
--------------------------------------------------------------
sda   SAMSUNG  MZ7LM240HCGR-00003  ATA     S1YFNXAG803838 disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/sda
Model:        SAMSUNG
Vendor:       MZ7LM240HCGR-00003
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              0.33 seconds
Operations:              1000
Write IOPS:              13333.33
Bandwidth:               52.08 MiB/s (54.61 MB/s)
Sync latency (min):      0.000011339 seconds
Sync latency (avg):      0.000012822 seconds
Sync latency (max):      0.000037400 seconds
Sync latency (p99):      0.000023424 seconds
Sync latency (stddev):   0.000002109 seconds
Theoretical max ops/s:   77990.18
FIO runtime:             0.001 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-284.11.1.el9_2.x86_64
CPU:           Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz
Memory:        31.23 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL    VENDOR              SERIAL  TYPE               
--------------------------------------------------------------
sda   SAMSUNG  MZ7LM240HCGR-00003  ATA     S1YFNXAG803838 disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/sda
Model:        SAMSUNG
Vendor:       MZ7LM240HCGR-00003
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              0.36 seconds
Operations:              1000
Write IOPS:              9259.26
Bandwidth:               144.68 MiB/s (151.70 MB/s)
Sync latency (min):      0.000011600 seconds
Sync latency (avg):      0.000015483 seconds
Sync latency (max):      0.000039431 seconds
Sync latency (p99):      0.000024704 seconds
Sync latency (stddev):   0.000003083 seconds
Theoretical max ops/s:   64585.13
FIO runtime:             0.001 seconds
================================================================================
```

### Dedicated Server 3

AMD Ryzen 5950X, 32GB, 500GB SATA SSD (512GB Samsung 850 Pro).

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /home/libmemcached/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-503.16.1.el9_5.x86_64
CPU:           AMD EPYC-Milan Processor
Memory:        7.50 GB
============================================================

============================================================
Storage Devices
============================================================
No storage devices detected or lsblk command not available.
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/vda4 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              2.75 seconds
Operations:              1000
Write IOPS:              390.78
Bandwidth:               1.53 MiB/s (1.60 MB/s)
Sync latency (min):      0.000035147 seconds
Sync latency (avg):      0.000050542 seconds
Sync latency (max):      0.000078188 seconds
Sync latency (p99):      0.000061696 seconds
Sync latency (stddev):   0.000004249 seconds
Theoretical max ops/s:   19785.57
FIO runtime:             0.003 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /home/libmemcached/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-503.16.1.el9_5.x86_64
CPU:           AMD EPYC-Milan Processor
Memory:        7.50 GB
============================================================

============================================================
Storage Devices
============================================================
No storage devices detected or lsblk command not available.
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/vda4 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              3.21 seconds
Operations:              1000
Write IOPS:              330.80
Bandwidth:               5.17 MiB/s (5.42 MB/s)
Sync latency (min):      0.000032400 seconds
Sync latency (avg):      0.000052424 seconds
Sync latency (max):      0.000086292 seconds
Sync latency (p99):      0.000075264 seconds
Sync latency (stddev):   0.000008607 seconds
Theoretical max ops/s:   19075.18
FIO runtime:             0.004 seconds
================================================================================
```

### Dedicated Server 4

OVH Intel E3-1270v6, 64GB, 2x450GB NVMe raid 1 (450GB Intel DC P3520 NVMe)

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            Rocky Linux 9.5 (Blue Onyx)
Kernel:        5.14.0-503.14.1.el9_5.x86_64
CPU:           Intel(R) Xeon(R) CPU E3-1270 v6 @ 3.80GHz
Memory:        62.24 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL  VENDOR         SERIAL              TYPE
-------------------------------------------------------
nvme0n1  INTEL  SSDPE2MX450G7  CVPF733600JC450RGN  disk
nvme1n1  INTEL  SSDPE2MX450G7  CVPF734300MV450RGN  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md3 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              0.79 seconds
Operations:              1000
Write IOPS:              1897.53
Bandwidth:               7.41 MiB/s (7.77 MB/s)
Sync latency (min):      0.000002697 seconds
Sync latency (avg):      0.000004161 seconds
Sync latency (max):      0.000026517 seconds
Sync latency (p99):      0.000022144 seconds
Sync latency (stddev):   0.000003750 seconds
Theoretical max ops/s:   240316.21
FIO runtime:             0.001 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            Rocky Linux 9.5 (Blue Onyx)
Kernel:        5.14.0-503.14.1.el9_5.x86_64
CPU:           Intel(R) Xeon(R) CPU E3-1270 v6 @ 3.80GHz
Memory:        62.24 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL  VENDOR         SERIAL              TYPE
-------------------------------------------------------
nvme0n1  INTEL  SSDPE2MX450G7  CVPF733600JC450RGN  disk
nvme1n1  INTEL  SSDPE2MX450G7  CVPF734300MV450RGN  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md3 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              0.82 seconds
Operations:              1000
Write IOPS:              1782.53
Bandwidth:               27.85 MiB/s (29.20 MB/s)
Sync latency (min):      0.000002788 seconds
Sync latency (avg):      0.000004112 seconds
Sync latency (max):      0.000025905 seconds
Sync latency (p99):      0.000020608 seconds
Sync latency (stddev):   0.000002913 seconds
Theoretical max ops/s:   243163.96
FIO runtime:             0.001 seconds
================================================================================
```

### Dedicated Server 5

Intel Xeon E-2236, 16GB, 512GB NVMe SSD (512GB Kingston KC3000 NVMe)

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            CentOS Linux 7 (Core)
Kernel:        3.10.0-1160.118.1.el7.x86_64
CPU:           Intel(R) Xeon(R) E-2236 CPU @ 3.40GHz
Memory:        15.42 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE
--------------------------------------------------------
nvme0n1  KINGSTON  SKC3000S1024G  50026B7686B341XX  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/nvme0n1
Model:        KINGSTON
Vendor:       SKC3000S1024G
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.88 seconds
Operations:              1000
Write IOPS:              701.26
Bandwidth:               2.74 MiB/s (2.87 MB/s)
Sync latency (min):      0.000104221 seconds
Sync latency (avg):      0.000128123 seconds
Sync latency (max):      0.000472925 seconds
Sync latency (p99):      0.000152576 seconds
Sync latency (stddev):   0.000013071 seconds
Theoretical max ops/s:   7805.00
FIO runtime:             1.000 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            CentOS Linux 7 (Core)
Kernel:        3.10.0-1160.118.1.el7.x86_64
CPU:           Intel(R) Xeon(R) E-2236 CPU @ 3.40GHz
Memory:        15.42 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE
--------------------------------------------------------
nvme0n1  KINGSTON  SKC3000S1024G  50026B7686B341XX  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/nvme0n1
Model:        KINGSTON
Vendor:       SKC3000S1024G
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.88 seconds
Operations:              1000
Write IOPS:              703.23
Bandwidth:               10.99 MiB/s (11.52 MB/s)
Sync latency (min):      0.000094679 seconds
Sync latency (avg):      0.000129106 seconds
Sync latency (max):      0.000371626 seconds
Sync latency (p99):      0.000156672 seconds
Sync latency (stddev):   0.000012832 seconds
Theoretical max ops/s:   7745.58
FIO runtime:             1.000 seconds
================================================================================
```

### Dedicated Server 6

AMD EPYC 7452, 128GB, 2x2TB NVMe raid 1 (2x2TB Kingston KC3000 NVMe)

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            CentOS Linux 7 (Core)
Kernel:        3.10.0-1160.118.1.el7.x86_64
CPU:           AMD EPYC 7452 32-Core Processor
Memory:        125.68 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE
--------------------------------------------------------
nvme0n1  KINGSTON  SKC3000D2048G  50026B7686B1A1XX  disk
nvme1n1  KINGSTON  SKC3000D2048G  50026B7686B1A0XX  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md126 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.85 seconds
Operations:              1000
Write IOPS:              758.73
Bandwidth:               2.96 MiB/s (3.11 MB/s)
Sync latency (min):      0.000102426 seconds
Sync latency (avg):      0.000120319 seconds
Sync latency (max):      0.001255708 seconds
Sync latency (p99):      0.000154624 seconds
Sync latency (stddev):   0.000033541 seconds
Theoretical max ops/s:   8311.25
FIO runtime:             1.000 seconds
================================================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            CentOS Linux 7 (Core)
Kernel:        3.10.0-1160.118.1.el7.x86_64
CPU:           AMD EPYC 7452 32-Core Processor
Memory:        125.68 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE
--------------------------------------------------------
nvme0n1  KINGSTON  SKC3000D2048G  50026B7686B1A1XX  disk
nvme1n1  KINGSTON  SKC3000D2048G  50026B7686B1A0XX  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md126 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.77 seconds
Operations:              1000
Write IOPS:              780.64
Bandwidth:               12.20 MiB/s (12.79 MB/s)
Sync latency (min):      0.000100673 seconds
Sync latency (avg):      0.000116798 seconds
Sync latency (max):      0.000792801 seconds
Sync latency (p99):      0.000144384 seconds
Sync latency (stddev):   0.000025892 seconds
Theoretical max ops/s:   8561.76
FIO runtime:             1.000 seconds
================================================================================
```

### Dedicated Server 7

AMD EPYC 7302P, 128GB, 4x1TB NVMe Raid 10 (4x1TB Kingston KC3000 NVMe) + 6x960GB SATA SSD (Kingston DC600M datacenter grade SATA SSD)

```bash
cat /proc/mdstat 
Personalities : [raid1] [raid10] 
md122 : active raid1 sdb4[0] sda4[1]
      525248 blocks super 1.0 [2/2] [UU]
      bitmap: 0/1 pages [0KB], 65536KB chunk

md123 : active raid10 sdf1[0] sde1[3] sdc1[1] sdd1[2]
      1875118080 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      bitmap: 0/14 pages [0KB], 65536KB chunk

md124 : active raid10 nvme3n1p1[3] nvme2n1p1[0] nvme1n1p1[2] nvme0n1p1[1]
      2000142336 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      bitmap: 3/15 pages [12KB], 65536KB chunk

md125 : active raid1 sdb2[0] sda2[1]
      4193280 blocks super 1.2 [2/2] [UU]
      
md126 : active raid1 sda1[1] sdb1[0]
      931134464 blocks super 1.2 [2/2] [UU]
      bitmap: 0/7 pages [0KB], 65536KB chunk

md127 : active raid1 sda3[1] sdb3[0]
      1047552 blocks super 1.2 [2/2] [UU]
      bitmap: 0/1 pages [0KB], 65536KB chunk

```

2x 960GB Kingston DC600M SATA SSD raid 1

```bash
python /root/tools/fsync_fio.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md126 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.03 seconds
Operations:              1000
Write IOPS:              1362.40
Bandwidth:               5.32 MiB/s (5.58 MB/s)
Sync latency (min):      0.000181885 seconds
Sync latency (avg):      0.000194993 seconds
Sync latency (max):      0.000263697 seconds
Sync latency (p99):      0.000234496 seconds
Sync latency (stddev):   0.000010652 seconds
Theoretical max ops/s:   5128.40
FIO runtime:             0.734 seconds
================================================================================
```

2x 960GB Kingston DC600M SATA SSD raid 1

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md126 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.10 seconds
Operations:              1000
Write IOPS:              1246.88
Bandwidth:               19.48 MiB/s (20.43 MB/s)
Sync latency (min):      0.000181865 seconds
Sync latency (avg):      0.000196847 seconds
Sync latency (max):      0.000254287 seconds
Sync latency (p99):      0.000226304 seconds
Sync latency (stddev):   0.000010325 seconds
Theoretical max ops/s:   5080.09
FIO runtime:             0.802 seconds
================================================================================
```

4x 1TB Kingston KC3000 NVMe Raid 10

```bash
python /root/tools/fsync_fio.py --non-interactive --force --output /var/testfile
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /var/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  /var/testfile
Device:       /dev/md124 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.54 seconds
Operations:              1000
Write IOPS:              819.67
Bandwidth:               3.20 MiB/s (3.36 MB/s)
Sync latency (min):      0.000117033 seconds
Sync latency (avg):      0.000126701 seconds
Sync latency (max):      0.000517844 seconds
Sync latency (p99):      0.000140288 seconds
Sync latency (stddev):   0.000010599 seconds
Theoretical max ops/s:   7892.57
FIO runtime:             1.220 seconds
================================================================================
```

4x 1TB Kingston KC3000 NVMe Raid 10

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force  --mmap-size 16384 --output /var/testfile
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /var/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  /var/testfile
Device:       /dev/md124 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.54 seconds
Operations:              1000
Write IOPS:              815.00
Bandwidth:               12.73 MiB/s (13.35 MB/s)
Sync latency (min):      0.000117203 seconds
Sync latency (avg):      0.000126493 seconds
Sync latency (max):      0.000406101 seconds
Sync latency (p99):      0.000140288 seconds
Sync latency (stddev):   0.000009914 seconds
Theoretical max ops/s:   7905.56
FIO runtime:             1.227 seconds
================================================================================
```

4x 960GB Kingston DC600M SATA SSD Raid 10

```bash
python /root/tools/fsync_fio.py --non-interactive --force --output /home/testfile
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /home/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  /home/testfile
Device:       /dev/md123 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.59 seconds
Operations:              1000
Write IOPS:              766.28
Bandwidth:               2.99 MiB/s (3.14 MB/s)
Sync latency (min):      0.000336689 seconds
Sync latency (avg):      0.000360230 seconds
Sync latency (max):      0.000491743 seconds
Sync latency (p99):      0.000411648 seconds
Sync latency (stddev):   0.000013534 seconds
Theoretical max ops/s:   2776.01
FIO runtime:             1.305 seconds
================================================================================
```

4x 960GB Kingston DC600M SATA SSD Raid 10

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync_fio.py --non-interactive --force  --mmap-size 16384 --output /home/testfile
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /home/testfile
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.5 (Teal Serval)
Kernel:        5.14.0-427.13.1.el9_4.x86_64
CPU:           AMD EPYC 7302P 16-Core Processor
Memory:        125.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL     VENDOR         SERIAL            TYPE                 
-------------------------------------------------------------------------
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED91XX disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED92XX disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BFXX  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183XX  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27AXX  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D9XX  disk             
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  /home/testfile
Device:       /dev/md123 (determined from path)
============================================================

Completed 100/1000 iterations (10.0%)
Completed 200/1000 iterations (20.0%)
Completed 300/1000 iterations (30.0%)
Completed 400/1000 iterations (40.0%)
Completed 500/1000 iterations (50.0%)
Completed 600/1000 iterations (60.0%)
Completed 700/1000 iterations (70.0%)
Completed 800/1000 iterations (80.0%)
Completed 900/1000 iterations (90.0%)
Completed 1000/1000 iterations (100.0%)

================================================================================
Test Results:
================================================================================
Total time:              1.64 seconds
Operations:              1000
Write IOPS:              742.39
Bandwidth:               11.60 MiB/s (12.16 MB/s)
Sync latency (min):      0.000338059 seconds
Sync latency (avg):      0.000362114 seconds
Sync latency (max):      0.000429912 seconds
Sync latency (p99):      0.000403456 seconds
Sync latency (stddev):   0.000012015 seconds
Theoretical max ops/s:   2761.56
FIO runtime:             1.347 seconds
================================================================================
```

