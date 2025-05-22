## 💾 Why Drive `fsync()` Performance Matters

When applications save data, they often rely on a system call called `fsync()` to ensure that data is physically written to the storage device. This is crucial for data integrity, especially in databases where losing recent transactions can be catastrophic.

**Key Points:**

* **Data Durability:** `fsync()` ensures that data is safely stored on disk, protecting against data loss during unexpected events like power failures.

* **Performance Impact:** The speed of `fsync()` operations varies across storage devices. Traditional hard drives (HDDs) have slower `fsync()` times compared to solid-state drives (SSDs), affecting how quickly applications can confirm data is saved.

* **Database Operations:** In databases like MySQL, `fsync()` is used to write transaction logs and data files. Slow `fsync()` performance can lead to increased latency for transactions, affecting overall database responsiveness.

* **Storage Choices:** Choosing storage with better `fsync()` performance (like enterprise-grade SSDs) can significantly improve application and database performance.

Understanding and optimizing `fsync()` performance is essential for building reliable and efficient systems.

## Examples

Example results for [fsync_fio_ext.py](https://github.com/centminmod/centminmod-sysbench/blob/master/scripts/fsync_fio_ext.py) (FIO read/write fsync test support)). These tests help evaluate drive performance under mixed workloads with synchronous writes, relevant for database-like scenarios as outlined at [https://www.percona.com/blog/fsync-performance-storage-devices/](https://www.percona.com/blog/fsync-performance-storage-devices/). Datacenter or enterprise NVMe/SATA SSDs generally exhibit superior `fsync` and mixed I/O performance.

The following table presents results for a random read/write (70% read/30% write) test with `fsync` on writes, using a 16KB block size over a 100MB file region (approximating the script's conditional default parameters for `randrw`: `--test-type randrw --mmap-size 16384 --file-size 100M --loops 1 --rwmixread 70 --sync-method fsync`). Results are ordered by Random Write IOPS (ascending):

| Server #                           | CPU                          | OS                | Storage                                         | Rand Read IOPS | Rand Read Latency (avg) (ms) | Rand Write IOPS | Rand Write Latency (avg) (ms) | Sync Latency (avg) (s) |
| :--------------------------------- | :--------------------------- | :---------------- | :---------------------------------------------- | -------------: | ---------------------------: | --------------: | ----------------------------: | ----------------------: |
| [Server 1](#dedicated-server-1)      | Intel Xeon E-2276G         | AlmaLinux 8.10    | 2x960G NVMe RAID1 (PM983+DC1500M)    | 6330.95        | 0.110                        | 2838.11         | 0.059                         | 0.000013334             |
| [Server 2](#dedicated-server-2)      | Intel Core i7-4790K        | AlmaLinux 9.5     | 240G Samsung PM863 SATA SSD          | 3138.49        | 0.217                        | 1406.96         | 0.112                         | 0.000033631             |
| [Server 5a](#dedicated-server-5)  | AMD EPYC 7302P               | AlmaLinux 9.5     | 2x960G KDC600M SATA RAID1          | 1386.14        | 0.226                        | 621.39          | 0.374                         | 0.000224942             |
| [Server 5b](#dedicated-server-5) | AMD EPYC 7302P               | AlmaLinux 9.5     | 4x1TB KKC3000 NVMe RAID10         | 1096.53        | 0.075                        | 491.56          | 0.944                         | 0.000284046             |
| [Server 5c](#dedicated-server-5) | AMD EPYC 7302P               | AlmaLinux 9.5     | 4x960G KDC600M SATA RAID10         | 924.67         | 0.227                        | 414.52          | 0.623                         | 0.000395175             |
| [Server 4](#dedicated-server-4)      | Intel Xeon E3-1270 v6      | Rocky Linux 9.5   | 2x450G Intel P3520 NVMe RAID1        | 726.21         | 0.371                        | 325.55          | 1.201                         | 0.000316592             |
| [Server 3](#dedicated-server-3)      | AMD Ryzen 9 5950X     | AlmaLinux 9.6     | 512GB Samsung 850 Pro SATA SSD                        | 567.78         | 0.068                        | 254.53          | 2.750                         | 0.000316261             |

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
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile.fio
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
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  testfile.fio
Device:       /dev/md1 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       2.02 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              2838.11
Write Bandwidth:         44.35 MiB/s (46.50 MB/s)
Write Latency (avg):     0.059 ms

--- Read Performance ---
Read IOPS:               6330.95
Read Bandwidth:          98.92 MiB/s (103.73 MB/s)
Read Latency (avg):      0.110 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000003106 seconds
Sync latency (avg):      0.000013334 seconds
Sync latency (max):      0.000207796 seconds
Sync latency (p99):      0.000142336 seconds
Sync latency (stddev):   0.000029076 seconds
Theoretical max sync ops/s: 74998.64 (based on avg sync latency)

FIO job runtime:         2.000 seconds
================================================================================

Cleanup: Removed test file 'testfile.fio'
```

### Dedicated Server 2

OVH Intel Core i7-4790K, 32GB, 240GB SATA SSD (Samsung PM863 Datacenter Grade SATA SSD)

```bash
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile.fio
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
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  testfile.fio
Device:       /dev/sda
Model:        SAMSUNG
Vendor:       MZ7LM240HCGR-00003
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       2.07 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              1406.96
Write Bandwidth:         21.98 MiB/s (23.05 MB/s)
Write Latency (avg):     0.112 ms

--- Read Performance ---
Read IOPS:               3138.49
Read Bandwidth:          49.04 MiB/s (51.42 MB/s)
Read Latency (avg):      0.217 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000011569 seconds
Sync latency (avg):      0.000033631 seconds
Sync latency (max):      0.000317766 seconds
Sync latency (p99):      0.000150528 seconds
Sync latency (stddev):   0.000039377 seconds
Theoretical max sync ops/s: 29734.07 (based on avg sync latency)

FIO job runtime:         2.000 seconds
================================================================================

Cleanup: Removed test file 'testfile.fio'
```

### Dedicated Server 3

AMD Ryzen 5950X, 32GB, 500GB SATA SSD (512GB Samsung 850 Pro).

```bash
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile.fio
Incorrect paths can lead to severe data loss or system damage.
------------------------------------------------------------

============================================================
System Information
============================================================
OS:            AlmaLinux 9.6 (Sage Margay)
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
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  testfile.fio
Device:       /dev/vda4 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       9.01 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              254.53
Write Bandwidth:         3.98 MiB/s (4.17 MB/s)
Write Latency (avg):     2.750 ms

--- Read Performance ---
Read IOPS:               567.78
Read Bandwidth:          8.87 MiB/s (9.30 MB/s)
Read Latency (avg):      0.068 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000029125 seconds
Sync latency (avg):      0.000316261 seconds
Sync latency (max):      0.006559083 seconds
Sync latency (p99):      0.001368064 seconds
Sync latency (stddev):   0.000598373 seconds
Theoretical max sync ops/s: 3161.95 (based on avg sync latency)

FIO job runtime:         8.000 seconds
================================================================================

Cleanup: Removed test file 'testfile.fio'
```

### Dedicated Server 4

OVH Intel E3-1270v6, 64GB, 2x450GB NVMe raid 1 (450GB Intel DC P3520 NVMe)

```bash
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile.fio
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
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  testfile.fio
Device:       /dev/md3 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       6.54 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              325.55
Write Bandwidth:         5.09 MiB/s (5.33 MB/s)
Write Latency (avg):     1.201 ms

--- Read Performance ---
Read IOPS:               726.21
Read Bandwidth:          11.35 MiB/s (11.90 MB/s)
Read Latency (avg):      0.371 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000002834 seconds
Sync latency (avg):      0.000316592 seconds
Sync latency (max):      0.002009006 seconds
Sync latency (p99):      0.001761280 seconds
Sync latency (stddev):   0.000594736 seconds
Theoretical max sync ops/s: 3158.64 (based on avg sync latency)

FIO job runtime:         7.000 seconds
================================================================================

Cleanup: Removed test file 'testfile.fio'
```

### Dedicated Server 5

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
/root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile.fio
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
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED916A disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A3 disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED923D disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A4 disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92B0 disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED9278 disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BF08  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183CD  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27ACC  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D974  disk                 
============================================================

============================================================
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  testfile.fio
Device:       /dev/md126 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       3.85 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              621.39
Write Bandwidth:         9.71 MiB/s (10.18 MB/s)
Write Latency (avg):     0.374 ms

--- Read Performance ---
Read IOPS:               1386.14
Read Bandwidth:          21.66 MiB/s (22.71 MB/s)
Read Latency (avg):      0.226 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000182896 seconds
Sync latency (avg):      0.000224942 seconds
Sync latency (max):      0.003073657 seconds
Sync latency (p99):      0.000354304 seconds
Sync latency (stddev):   0.000063081 seconds
Theoretical max sync ops/s: 4445.59 (based on avg sync latency)

FIO job runtime:         4.000 seconds
================================================================================

Cleanup: Removed test file 'testfile.fio'
```

4x 1TB Kingston KC3000 NVMe Raid 10

```bash
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force --output /var/testfile
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
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED916A disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A3 disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED923D disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A4 disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92B0 disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED9278 disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BF08  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183CD  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27ACC  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D974  disk                 
============================================================

============================================================
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  /var/testfile
Device:       /dev/md124 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       4.52 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              491.56
Write Bandwidth:         7.68 MiB/s (8.05 MB/s)
Write Latency (avg):     0.944 ms

--- Read Performance ---
Read IOPS:               1096.53
Read Bandwidth:          17.13 MiB/s (17.97 MB/s)
Read Latency (avg):      0.075 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000110434 seconds
Sync latency (avg):      0.000284046 seconds
Sync latency (max):      0.005714290 seconds
Sync latency (p99):      0.000888832 seconds
Sync latency (stddev):   0.000411865 seconds
Theoretical max sync ops/s: 3520.55 (based on avg sync latency)

FIO job runtime:         5.000 seconds
================================================================================

Cleanup: Removed test file '/var/testfile'
```

4x 960GB Kingston DC600M SATA SSD Raid 10

```bash
python /root/tools/fsync_fio_ext.py --test-type randrw --non-interactive --force --output /home/testfile
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
sda      KINGSTON  SEDC600M960G   ATA               50026B7686ED916A disk
sdb      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A3 disk
sdc      KINGSTON  SEDC600M960G   ATA               50026B7686ED923D disk
sdd      KINGSTON  SEDC600M960G   ATA               50026B7686ED92A4 disk
sde      KINGSTON  SEDC600M960G   ATA               50026B7686ED92B0 disk
sdf      KINGSTON  SEDC600M960G   ATA               50026B7686ED9278 disk
nvme0n1  KINGSTON  SKC3000S1024G  50026B7685E0BF08  disk                 
nvme1n1  KINGSTON  SKC3000S1024G  50026B7686B183CD  disk                 
nvme3n1  KINGSTON  SKC3000S1024G  50026B7686C27ACC  disk                 
nvme2n1  KINGSTON  SKC3000S1024G  50026B7686B3D974  disk                 
============================================================

============================================================
FIO Storage Performance Test
============================================================
Test Type:    randrw
Sync method:  fsync (for writes)
Op size:      16384 bytes (fio bs)
Operations:   1 (fio loops)
File size:    100M (fio size)
Read mix %:   70
Output file:  /home/testfile
Device:       /dev/md123 (determined from path)
============================================================

Running randrw test (sync method: fsync, ops: 1)...
Test completed successfully!

================================================================================
Test Results (randrw, fsync):
================================================================================
Total script time:       5.29 seconds
Operations requested:    1

--- Write Performance ---
Write IOPS:              414.52
Write Bandwidth:         6.48 MiB/s (6.79 MB/s)
Write Latency (avg):     0.623 ms

--- Read Performance ---
Read IOPS:               924.67
Read Bandwidth:          14.45 MiB/s (15.15 MB/s)
Read Latency (avg):      0.227 ms

--- Sync Performance (for writes) ---
Sync latency (min):      0.000338679 seconds
Sync latency (avg):      0.000395175 seconds
Sync latency (max):      0.000944317 seconds
Sync latency (p99):      0.000569344 seconds
Sync latency (stddev):   0.000076392 seconds
Theoretical max sync ops/s: 2530.53 (based on avg sync latency)

FIO job runtime:         5.000 seconds
================================================================================

Cleanup: Removed test file '/home/testfile'
```
