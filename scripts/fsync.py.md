## 💾 Why Drive `fsync()` Performance Matters

When applications save data, they often rely on a system call called `fsync()` to ensure that data is physically written to the storage device. This is crucial for data integrity, especially in databases where losing recent transactions can be catastrophic.

**Key Points:**

* **Data Durability:** `fsync()` ensures that data is safely stored on disk, protecting against data loss during unexpected events like power failures.

* **Performance Impact:** The speed of `fsync()` operations varies across storage devices. Traditional hard drives (HDDs) have slower `fsync()` times compared to solid-state drives (SSDs), affecting how quickly applications can confirm data is saved.

* **Database Operations:** In databases like MySQL, `fsync()` is used to write transaction logs and data files. Slow `fsync()` performance can lead to increased latency for transactions, affecting overall database responsiveness.

* **Storage Choices:** Choosing storage with better `fsync()` performance (like enterprise-grade SSDs) can significantly improve application and database performance.

Understanding and optimizing `fsync()` performance is essential for building reliable and efficient systems.

## Examples

Example results for [fsync.py](https://github.com/centminmod/centminmod-sysbench/blob/master/scripts/fsync.py) (alternative to [sysbench fsync benchmark test](https://github.com/centminmod/centminmod-sysbench/tree/master#sysbench-fileio-fsync)) to test various dedicated servers' drives and their fsync performance as outlined at https://www.percona.com/blog/fsync-performance-storage-devices/. You can see that datacenter or enterprise NVMe/SATA SSD have much faster fsync performance than regularly consumer SATA SSD or consumer NVMe drives.

**For `4096 bytes` fsync test:**

| Server # | CPU | OS | Kernel | Storage | Fsync Operations/sec | Avg time per op (ms) |
|----------|-----|-------|--------|---------|---------------|----------------------|
| [1](#dedicated-server-1) | Intel Xeon E-2276G | AlmaLinux 8.10 | 4.18.0-425.19.2.el8_7.x86_64 | 2x 960GB NVMe RAID 1 (Samsung PM983 + Kingston DC1500M) | 40,473.06 | 0.025 |
| [2](#dedicated-server-2) | Intel Core i7-4790K | AlmaLinux 9.5 | 5.14.0-284.11.1.el9_2.x86_64 | 240GB Samsung PM863 SATA SSD | 25,394.32 | 0.039 |
| [7a](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 2x 960GB Kingston DC600M SATA SSD raid 1 | 3,602.94 | 0.278 |
| [7c](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 960GB Kingston DC600M SATA SSD Raid 10 | 2,077.99| 0.481 |
| [4](#dedicated-server-4) | Intel Xeon E3-1270 v6 | Rocky Linux 9.5 | 5.14.0-503.14.1.el9_5.x86_64 | 2x 450GB Intel DC P3520 NVMe RAID 1 | 2,026.88 | 0.493 |
| [6](#dedicated-server-6) | AMD EPYC 7452 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 2x 2TB Kingston KC3000 NVMe RAID 1 | 1,691.09 | 0.591 |
| [7b](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 1TB Kingston KC3000 NVMe Raid 10 | 1,280.95 | 0.781 |
| [5](#dedicated-server-5) | Intel Xeon E-2236 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 512GB Kingston KC3000 NVMe | 1,001.50 | 0.999 |
| [10](#dedicated-server-10) | Intel Xeon E5-1650 v4 | CentOS Linux 7 | 3.10.0-957.10.1.el7.x86_64 | 2x 256GB Micron 1100 SATA SSD RAID 1 | 652.10 | 1.534 |
| [3](#dedicated-server-3) | AMD Ryzen 9 5950X | AlmaLinux 9.5 | 5.14.0-503.23.2.el9_5.x86_64 | 512GB Samsung 850 Pro SATA SSD | 442.55 | 2.260 |
| [8](#dedicated-server-8) | AMD Ryzen 7 PRO 8700GE | AlmaLinux 9.5 | 5.14.0-503.23.2.el9_5.x86_64 | 2x 512GB Samsung PM9A1 NVMe raid 1 SSD | 167.49 | 5.970 |
| [9](#dedicated-server-9) | Dual Intel Xeon Gold 6226R | CentOS Linux 7 | 3.10.0-1160.95.1.el7.x86_64 | 4x 2TB Samsung 860 EVO SATA SSD RAID 10 (AVAGO MegaRAID SAS 9341-4i) | 83.04 | 12.043 |

**For `16384 bytes` fsync test:**

| Server # | CPU | OS | Kernel | Storage | Fsync Operations/sec | Avg time per op (ms) |
|----------|-----|-------|--------|---------|---------------|----------------------|
| [1](#dedicated-server-1) | Intel Xeon E-2276G | AlmaLinux 8.10 | 4.18.0-425.19.2.el8_7.x86_64 | 2x 960GB NVMe RAID 1 (Samsung PM983 + Kingston DC1500M) | 30,369.08 | 0.033 |
| [2](#dedicated-server-2) | Intel Core i7-4790K | AlmaLinux 9.5 | 5.14.0-284.11.1.el9_2.x86_64 | 240GB Samsung PM863 SATA SSD | 13,476.93 | 0.074 |
| [7a](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 2x 960GB Kingston DC600M SATA SSD raid 1 | 3,209.11| 0.312 |
| [7c](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 960GB Kingston DC600M SATA SSD Raid 10 | 1,988.64| 0.503 |
| [4](#dedicated-server-4) | Intel Xeon E3-1270 v6 | Rocky Linux 9.5 | 5.14.0-503.14.1.el9_5.x86_64 | 2x 450GB Intel DC P3520 NVMe RAID 1 | 1,750.92 | 0.571 |
| [6](#dedicated-server-6) | AMD EPYC 7452 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 2x 2TB Kingston KC3000 NVMe RAID 1 | 1,506.84 | 0.664 |
| [7b](#dedicated-server-7) | AMD EPYC 7302P | AlmaLinux 9.5 | 5.14.0-427.13.1.el9_4.x86_64 | 4x 1TB Kingston KC3000 NVMe Raid 10 | 1,222.16 | 0.818 |
| [5](#dedicated-server-5) | Intel Xeon E-2236 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 512GB Kingston KC3000 NVMe | 986.98 | 1.013 |
| [10](#dedicated-server-10) | Intel Xeon E5-1650 v4 | CentOS Linux 7 | 3.10.0-957.10.1.el7.x86_64 | 2x 256GB Micron 1100 SATA SSD RAID 1 | 640.79 | 1.561 |
| [3](#dedicated-server-3) | AMD Ryzen 9 5950X | AlmaLinux 9.5 | 5.14.0-503.23.2.el9_5.x86_64 | 512GB Samsung 850 Pro SATA SSD | 396.10 | 2.525 |
| [8](#dedicated-server-8) | AMD Ryzen 7 PRO 8700GE | AlmaLinux 9.5 | 5.14.0-503.23.2.el9_5.x86_64 | 2x 512GB Samsung PM9A1 NVMe raid 1 SSD | 164.78 | 6.069 |
| [9](#dedicated-server-9) | Dual Intel Xeon Gold 6226R | CentOS Linux 7 | 3.10.0-1160.95.1.el7.x86_64 | 4x 2TB Samsung 860 EVO SATA SSD RAID 10 (AVAGO MegaRAID SAS 9341-4i) | 79.19 | 12.629 |

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
python /root/tools/fsync.py --non-interactive --force
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

============================================================
Test Results:
============================================================
Total time:        0.02 seconds
Operations:        1000
Operations/sec:    40473.06
Avg time per op:   0.025 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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

============================================================
Test Results:
============================================================
Total time:        0.03 seconds
Operations:        1000
Operations/sec:    30369.08
Avg time per op:   0.033 ms
============================================================
```

### Dedicated Server 2

OVH Intel Core i7-4790K, 32GB, 240GB SATA SSD (Samsung PM863 Datacenter Grade SATA SSD)

```bash
python /root/tools/fsync.py --non-interactive --force
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

============================================================
Test Results:
============================================================
Total time:        0.04 seconds
Operations:        1000
Operations/sec:    25394.32
Avg time per op:   0.039 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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

============================================================
Test Results:
============================================================
Total time:        0.07 seconds
Operations:        1000
Operations/sec:    13476.93
Avg time per op:   0.074 ms
============================================================
```

### Dedicated Server 3

AMD Ryzen 5950X, 32GB, 500GB SATA SSD (512GB Samsung 850 Pro).

```bash
python /root/tools/fsync.py --non-interactive --force
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
Kernel:        5.14.0-503.23.2.el9_5.x86_64
CPU:           AMD Ryzen 9 5950X 16-Core Processor
Memory:        30.98 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL    VENDOR  SERIAL  TYPE                                   
----------------------------------------------------------------------
sda   Samsung  SSD     850     PRO 512GB ATA      S39FNX0HB17146D disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/mapper/almalinux-root (determined from path)
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

============================================================
Test Results:
============================================================
Total time:        2.26 seconds
Operations:        1000
Operations/sec:    442.55
Avg time per op:   2.260 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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
Kernel:        5.14.0-503.23.2.el9_5.x86_64
CPU:           AMD Ryzen 9 5950X 16-Core Processor
Memory:        30.98 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL    VENDOR  SERIAL  TYPE                                   
----------------------------------------------------------------------
sda   Samsung  SSD     850     PRO 512GB ATA      S39FNX0HB17146D disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/mapper/almalinux-root (determined from path)
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

============================================================
Test Results:
============================================================
Total time:        2.52 seconds
Operations:        1000
Operations/sec:    396.10
Avg time per op:   2.525 ms
============================================================
```

### Dedicated Server 4

OVH Intel E3-1270v6, 64GB, 2x450GB NVMe raid 1 (450GB Intel DC P3520 NVMe)

```bash
python /root/tools/fsync.py --non-interactive --force
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.49 seconds
Operations:        1000
Operations/sec:    2026.88
Avg time per op:   0.493 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
------------------------------------------------------------
WARNING: This script is running as root!
Please be absolutely sure that the output path is correct:
  Output file: /root/tools/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.57 seconds
Operations:        1000
Operations/sec:    1750.92
Avg time per op:   0.571 ms
============================================================
```

### Dedicated Server 5

Intel Xeon E-2236, 16GB, 512GB NVMe SSD (512GB Kingston KC3000 NVMe)

```bash
python /root/tools/fsync.py --non-interactive --force
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

============================================================
Test Results:
============================================================
Total time:        1.00 seconds
Operations:        1000
Operations/sec:    1001.50
Avg time per op:   0.999 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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

============================================================
Test Results:
============================================================
Total time:        1.01 seconds
Operations:        1000
Operations/sec:    986.98
Avg time per op:   1.013 ms
============================================================
```

### Dedicated Server 6

AMD EPYC 7452, 128GB, 2x2TB NVMe raid 1 (2x2TB Kingston KC3000 NVMe)

```bash
python /root/tools/fsync.py --non-interactive --force
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

============================================================
Test Results:
============================================================
Total time:        0.59 seconds
Operations:        1000
Operations/sec:    1691.09
Avg time per op:   0.591 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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

============================================================
Test Results:
============================================================
Total time:        0.66 seconds
Operations:        1000
Operations/sec:    1506.84
Avg time per op:   0.664 ms
============================================================
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
python /root/tools/fsync.py --non-interactive --force
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

============================================================
Test Results:
============================================================
Total time:        0.28 seconds
Operations:        1000
Operations/sec:    3602.94
Avg time per op:   0.278 ms
============================================================
```

2x 960GB Kingston DC600M SATA SSD raid 1

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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

============================================================
Test Results:
============================================================
Total time:        0.31 seconds
Operations:        1000
Operations/sec:    3209.11
Avg time per op:   0.312 ms
============================================================
```

4x 1TB Kingston KC3000 NVMe Raid 10

```bash
python /root/tools/fsync.py --non-interactive --force --output /var/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.78 seconds
Operations:        1000
Operations/sec:    1280.95
Avg time per op:   0.781 ms
============================================================
```

4x 1TB Kingston KC3000 NVMe Raid 10

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force  --mmap-size 16384 --output /var/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.82 seconds
Operations:        1000
Operations/sec:    1222.16
Avg time per op:   0.818 ms
============================================================
```

4x 960GB Kingston DC600M SATA SSD Raid 10

```bash
python /root/tools/fsync.py --non-interactive --force --output /home/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.48 seconds
Operations:        1000
Operations/sec:    2077.99
Avg time per op:   0.481 ms
============================================================
```

4x 960GB Kingston DC600M SATA SSD Raid 10

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force  --mmap-size 16384 --output /home/testfile
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

============================================================
Test Results:
============================================================
Total time:        0.50 seconds
Operations:        1000
Operations/sec:    1988.64
Avg time per op:   0.503 ms
============================================================
```

### Dedicated Server 8

Hetzner AX42 - AMD Ryzen 7 PRO 8700GE, 64GB, 2x 512GB Samsung PM9A1 NVMe raid 1

```bash
python /root/tools/fsync.py --non-interactive --force
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
Kernel:        5.14.0-503.23.1.el9_5.x86_64
CPU:           AMD Ryzen 7 PRO 8700GE w/ Radeon 780M Graphics
Memory:        60.30 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL    VENDOR              SERIAL          TYPE
----------------------------------------------------------
nvme0n1  SAMSUNG  MZVL2512HCJQ-00B07  S63CNF0W5305XX  disk
nvme1n1  SAMSUNG  MZVL2512HCJQ-00B07  S63CNF0W5296XX  disk
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

============================================================
Test Results:
============================================================
Total time:        5.97 seconds
Operations:        1000
Operations/sec:    167.49
Avg time per op:   5.970 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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
Kernel:        5.14.0-503.23.1.el9_5.x86_64
CPU:           AMD Ryzen 7 PRO 8700GE w/ Radeon 780M Graphics
Memory:        60.30 GB
============================================================

============================================================
Storage Devices
============================================================
NAME     MODEL    VENDOR              SERIAL          TYPE
----------------------------------------------------------
nvme0n1  SAMSUNG  MZVL2512HCJQ-00B07  S63CNF0W5305XX  disk
nvme1n1  SAMSUNG  MZVL2512HCJQ-00B07  S63CNF0W5296XX  disk
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

============================================================
Test Results:
============================================================
Total time:        6.07 seconds
Operations:        1000
Operations/sec:    164.78
Avg time per op:   6.069 ms
============================================================
```

### Dedicated Server 9

Dual Intel Xeon Gold 6226R, 128GB, 4x 2TB Samsung 860 EVO SATA SSD hardware Raid 10 with AVAGO MegaRAID SAS 9341-4i controller

```bash
python /root/tools/fsync.py --non-interactive --force
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
Kernel:        3.10.0-1160.95.1.el7.x86_64
CPU:           Intel(R) Xeon(R) Gold 6226R CPU @ 2.90GHz
Memory:        125.25 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL             VENDOR  SERIAL                            TYPE
----------------------------------------------------------------------
sda   ST8000NM000A-2KE  ATA     WSD5MM7D                          disk
sdb   MR9341-4i         AVAGO   600605b00fb85ea029ce853005cb1967  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/sdb
Model:        MR9341-4i
Vendor:       AVAGO
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

============================================================
Test Results:
============================================================
Total time:        12.04 seconds
Operations:        1000
Operations/sec:    83.04
Avg time per op:   12.043 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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
Kernel:        3.10.0-1160.95.1.el7.x86_64
CPU:           Intel(R) Xeon(R) Gold 6226R CPU @ 2.90GHz
Memory:        125.25 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL             VENDOR  SERIAL                            TYPE
----------------------------------------------------------------------
sda   ST8000NM000A-2KE  ATA     WSD5MM7D                          disk
sdb   MR9341-4i         AVAGO   600605b00fb85ea029ce853005cb1967  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/sdb
Model:        MR9341-4i
Vendor:       AVAGO
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

============================================================
Test Results:
============================================================
Total time:        12.63 seconds
Operations:        1000
Operations/sec:    79.19
Avg time per op:   12.629 ms
============================================================
```

### Dedicated Server 10

Intel Xeon E5-1650 v4, 32GB, 2 sets of 2x256GB Micron 1100 SATA SSD software Raid 1

```bash
python /root/tools/fsync.py --non-interactive --force
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
Kernel:        3.10.0-957.10.1.el7.x86_64
CPU:           Intel(R) Xeon(R) CPU E5-1650 v4 @ 3.60GHz
Memory:        31.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL             VENDOR   SERIAL            TYPE
-------------------------------------------------------
sda   Micron_1100_MTFD  ATA      170415823026      disk
sdb   Micron_1100_MTFD  ATA      171917973393      disk
sdc   ST1000NM0033-9ZM  ATA      Z1W1NN1C          disk
sdd   SQL               ASR8405  acf0067c00d00000  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  4096 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md127 (determined from path)
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

============================================================
Test Results:
============================================================
Total time:        1.53 seconds
Operations:        1000
Operations/sec:    652.10
Avg time per op:   1.534 ms
============================================================
```

`--mmap-size 16384` 16KB test

```bash
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
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
Kernel:        3.10.0-957.10.1.el7.x86_64
CPU:           Intel(R) Xeon(R) CPU E5-1650 v4 @ 3.60GHz
Memory:        31.15 GB
============================================================

============================================================
Storage Devices
============================================================
NAME  MODEL             VENDOR   SERIAL            TYPE
-------------------------------------------------------
sda   Micron_1100_MTFD  ATA      170415823026      disk
sdb   Micron_1100_MTFD  ATA      171917973393      disk
sdc   ST1000NM0033-9ZM  ATA      Z1W1NN1C          disk
sdd   SQL               ASR8405  acf0067c00d00000  disk
============================================================

============================================================
Storage Sync Performance Test
============================================================
Sync method:  fsync
Memory size:  16384 bytes
Iterations:   1000
Output file:  testfile
Device:       /dev/md127 (determined from path)
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

============================================================
Test Results:
============================================================
Total time:        1.56 seconds
Operations:        1000
Operations/sec:    640.79
Avg time per op:   1.561 ms
============================================================
```
