## 💾 Why Drive `fsync()` Performance Matters

When applications save data, they often rely on a system call called `fsync()` to ensure that data is physically written to the storage device. This is crucial for data integrity, especially in databases where losing recent transactions can be catastrophic.

**Key Points:**

* **Data Durability:** `fsync()` ensures that data is safely stored on disk, protecting against data loss during unexpected events like power failures.

* **Performance Impact:** The speed of `fsync()` operations varies across storage devices. Traditional hard drives (HDDs) have slower `fsync()` times compared to solid-state drives (SSDs), affecting how quickly applications can confirm data is saved.

* **Database Operations:** In databases like MySQL, `fsync()` is used to write transaction logs and data files. Slow `fsync()` performance can lead to increased latency for transactions, affecting overall database responsiveness.

* **Storage Choices:** Choosing storage with better `fsync()` performance (like enterprise-grade SSDs) can significantly improve application and database performance.

Understanding and optimizing `fsync()` performance is essential for building reliable and efficient systems.

## Replicate Below Tests


```bash
mkdir -p /root/tools
cd /root/tools
wget -4 -O fsync.py https://github.com/centminmod/centminmod-sysbench/raw/refs/heads/master/scripts/fsync.py
chmod +x fsync.py
# may need to use python3 instead of python
python /root/tools/fsync.py --non-interactive --force
python /root/tools/fsync.py --non-interactive --force --mmap-size 16384
```

## Examples

Example results for [fsync.py](https://github.com/centminmod/centminmod-sysbench/blob/master/scripts/fsync.py) (alternative to [sysbench fsync benchmark test](https://github.com/centminmod/centminmod-sysbench/tree/master#sysbench-fileio-fsync)) to test various dedicated servers' drives and their fsync performance as outlined at https://www.percona.com/blog/fsync-performance-storage-devices/. You can see that datacenter or enterprise NVMe/SATA SSD have much faster fsync performance than regularly consumer SATA SSD or consumer NVMe drives.

Check [fsync.py - Pure Fsync Performance Analysis](#fsyncpy---pure-fsync-performance-analysis)

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

## fsync.py - Pure Fsync Performance Analysis

### **Deep Technical Methodology**

**🔧 Actual Implementation Analysis:**
```python
# Key technical details from fsync.py:

# 1. Direct I/O Implementation
fd = os.open(output_file, os.O_RDWR|os.O_CREAT|os.O_DIRECT|os.O_TRUNC, 0o600)
# O_DIRECT bypasses kernel page cache - data goes directly to storage controller
# This mimics database behavior where consistency is critical

# 2. Memory-mapped I/O
m = mmap.mmap(-1, mmap_size)  # Anonymous memory map
# Creates memory region not associated with any file descriptor
# Allows modification before writing to storage

# 3. The Core Test Loop
for i in range(1, iterations + 1):
    os.lseek(fd, 0, os.SEEK_SET)    # Reset file position
    m[1] = 49 if PY3 else '1'       # Modify memory map
    os.write(fd, m)                 # Write to file descriptor
    sync_method_func(fd)            # fsync() or fdatasync() call
```

**🔍 Laymen Explanation:**
This test is like having a single bank teller who must complete every transaction by walking to the vault to physically secure each deposit. The test measures how long each trip to the vault takes. In real applications, this represents how long it takes to guarantee that critical data (like a bank transaction or online order) is permanently saved and won't be lost if the power goes out.

### **Database Server Implications - Enterprise Scale**

#### **MySQL InnoDB Engine Deep Analysis**

**🔍 Laymen Explanation:**
MySQL's InnoDB engine is like a sophisticated banking system that keeps detailed records of every transaction. Every time someone transfers money, the system must write multiple records: the transaction log (for recovery), the account balances, and audit records. The fsync performance determines how quickly these records can be safely written to the permanent vault.

**🔧 Technical Implementation - Production MySQL Configuration:**

**Transaction Processing Architecture:**
```sql
-- Server 1 (40,473 fsync ops/sec) - Enterprise Configuration:

-- InnoDB Log Configuration for High-Performance Storage
SET GLOBAL innodb_log_file_size = 1024MB;           -- Large log files for efficiency
SET GLOBAL innodb_log_buffer_size = 256MB;          -- Massive log buffer for batching
SET GLOBAL innodb_flush_log_at_trx_commit = 1;      -- Full ACID compliance
SET GLOBAL innodb_flush_method = O_DIRECT;          -- Match fsync.py test methodology
SET GLOBAL innodb_io_capacity = 10000;              -- High I/O capacity
SET GLOBAL innodb_io_capacity_max = 20000;          -- Peak I/O during stress

-- Buffer Pool Optimization
SET GLOBAL innodb_buffer_pool_size = 128GB;         -- Assume 256GB RAM server
SET GLOBAL innodb_buffer_pool_instances = 32;       -- High concurrency
SET GLOBAL innodb_adaptive_flushing = ON;           -- Dynamic flushing
SET GLOBAL innodb_max_dirty_pages_pct = 90;         -- Allow high dirty page %

-- Expected Performance Characteristics:
-- Transaction throughput: 30,000-40,000 TPS sustainable
-- Commit latency: <1ms average, <3ms 99th percentile
-- Recovery time after crash: 1-2 minutes
-- Suitable for: Major e-commerce platforms, financial systems, SaaS platforms

-- Server 9 (83 fsync ops/sec) - Survival Configuration:
SET GLOBAL innodb_log_file_size = 64MB;             -- Minimal log files
SET GLOBAL innodb_log_buffer_size = 16MB;           -- Small buffer to reduce impact
SET GLOBAL innodb_flush_log_at_trx_commit = 2;      -- Compromise durability for usability
SET GLOBAL innodb_flush_method = O_DSYNC;           -- Sometimes faster on poor storage
SET GLOBAL innodb_io_capacity = 50;                 -- Very conservative
SET GLOBAL innodb_io_capacity_max = 100;            -- Limited peak capacity

-- Buffer Pool Restrictions
SET GLOBAL innodb_buffer_pool_size = 2GB;           -- Tiny buffer pool
SET GLOBAL innodb_buffer_pool_instances = 2;        -- Minimal instances
SET GLOBAL innodb_adaptive_flushing = OFF;          -- Disable dynamic flushing
SET GLOBAL innodb_max_dirty_pages_pct = 50;         -- Force early flushing

-- Expected Performance Characteristics:
-- Transaction throughput: 50-80 TPS maximum
-- Commit latency: 12ms+ average, >50ms 99th percentile
-- Recovery time after crash: 10+ minutes
-- Suitable for: Only small personal projects, development environments
```

**Real-World Transaction Scenarios:**

**Financial Services Application:**
```sql
-- High-frequency trading transaction (typical Wall Street workload):
DELIMITER $$
CREATE PROCEDURE ExecuteTradeOrder(
    IN account_id BIGINT,
    IN symbol VARCHAR(10),
    IN order_type ENUM('BUY', 'SELL'),
    IN quantity INT,
    IN price DECIMAL(10,4),
    IN order_id VARCHAR(36)
)
BEGIN
    DECLARE current_position INT DEFAULT 0;
    DECLARE account_balance DECIMAL(15,2) DEFAULT 0;
    DECLARE trade_value DECIMAL(15,2);
    DECLARE compliance_approved BOOLEAN DEFAULT FALSE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        -- Critical: Log failed trade for regulatory compliance (triggers fsync)
        INSERT INTO trade_failures (account_id, symbol, order_id, failure_time, reason)
        VALUES (account_id, symbol, order_id, UNIX_TIMESTAMP(NOW(6)), 'EXECUTION_FAILED');
        RESIGNAL;
    END;
    
    -- Calculate trade value
    SET trade_value = quantity * price;
    
    START TRANSACTION;
    
    -- 1. Lock and verify account (READ with row lock)
    SELECT cash_balance, margin_available INTO account_balance, @margin
    FROM trading_accounts 
    WHERE account_id = account_id FOR UPDATE;
    
    -- 2. Lock and verify current position (READ with row lock)
    SELECT COALESCE(quantity, 0) INTO current_position
    FROM positions 
    WHERE account_id = account_id AND symbol = symbol FOR UPDATE;
    
    -- 3. Risk management check (READ operations)
    CALL CheckRiskLimits(account_id, symbol, order_type, quantity, price, compliance_approved);
    
    IF NOT compliance_approved THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trade rejected by risk management';
    END IF;
    
    -- 4. Update account balance (WRITE - triggers fsync)
    IF order_type = 'BUY' THEN
        IF account_balance < trade_value THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
        END IF;
        UPDATE trading_accounts 
        SET cash_balance = cash_balance - trade_value,
            last_trade_time = NOW(6)
        WHERE account_id = account_id;
    ELSE -- SELL
        UPDATE trading_accounts 
        SET cash_balance = cash_balance + trade_value,
            last_trade_time = NOW(6)
        WHERE account_id = account_id;
    END IF;
    
    -- 5. Update position (WRITE - triggers fsync)
    INSERT INTO positions (account_id, symbol, quantity, avg_cost, last_updated)
    VALUES (account_id, symbol, 
            CASE order_type WHEN 'BUY' THEN quantity ELSE -quantity END,
            price, NOW(6))
    ON DUPLICATE KEY UPDATE
        quantity = quantity + CASE order_type WHEN 'BUY' THEN VALUES(quantity) ELSE -VALUES(quantity) END,
        avg_cost = CASE 
            WHEN (quantity + CASE order_type WHEN 'BUY' THEN VALUES(quantity) ELSE -VALUES(quantity) END) = 0 THEN 0
            ELSE ((quantity * avg_cost) + (VALUES(quantity) * VALUES(avg_cost))) / 
                 (quantity + CASE order_type WHEN 'BUY' THEN VALUES(quantity) ELSE -VALUES(quantity) END)
        END,
        last_updated = VALUES(last_updated);
    
    -- 6. Record trade execution (WRITE - triggers fsync)
    INSERT INTO trade_executions (
        order_id, account_id, symbol, order_type, quantity, execution_price,
        execution_time, trade_value, commission, settlement_date
    ) VALUES (
        order_id, account_id, symbol, order_type, quantity, price,
        NOW(6), trade_value, trade_value * 0.001, DATE_ADD(CURDATE(), INTERVAL 2 DAY)
    );
    
    -- 7. Regulatory reporting (WRITE - triggers fsync)
    INSERT INTO regulatory_trades (
        trade_id, account_id, symbol, side, quantity, price, 
        execution_timestamp, reporting_timestamp, market_center
    ) VALUES (
        LAST_INSERT_ID(), account_id, symbol, order_type, quantity, price,
        UNIX_TIMESTAMP(NOW(6)), UNIX_TIMESTAMP(NOW(6)), 'NASDAQ'
    );
    
    -- 8. Risk monitoring update (WRITE - triggers fsync)
    INSERT INTO position_risk_snapshot (
        account_id, symbol, position_quantity, market_value, timestamp
    ) VALUES (
        account_id, symbol, current_position + CASE order_type WHEN 'BUY' THEN quantity ELSE -quantity END,
        (current_position + CASE order_type WHEN 'BUY' THEN quantity ELSE -quantity END) * price,
        NOW(6)
    );
    
    COMMIT; -- Final transaction log fsync
END$$

-- Performance Analysis:
-- Total fsync operations per trade: ~6 (5 table writes + 1 commit log)

-- Server 1 Trading Performance:
-- 40,473 fsync ops/sec ÷ 6 ops/trade = 6,745 trades/second theoretical maximum
-- Real-world with network/CPU overhead: 3,000-4,000 trades/second sustainable
-- Latency per trade: <2ms average, <5ms 99th percentile
-- Daily volume capacity: ~250 million trades/day
-- Suitable for: NYSE, NASDAQ, major broker-dealers, high-frequency trading firms

-- Server 9 Trading Performance:
-- 83 fsync ops/sec ÷ 6 ops/trade = 13 trades/second theoretical maximum
-- Real-world: 5-8 trades/second maximum
-- Latency per trade: 150ms+ average, >500ms 99th percentile
-- Daily volume capacity: ~40,000 trades/day
-- Suitable for: Completely inadequate for any real financial trading platform
-- Would violate regulatory requirements for trade execution speed
```

**E-commerce Platform - Black Friday Scale:**
```sql
-- Complex e-commerce order processing (Amazon/eBay scale):
DELIMITER $$
CREATE PROCEDURE ProcessComplexOrder(
    IN customer_id BIGINT,
    IN shipping_address_id BIGINT,
    IN payment_method_id BIGINT,
    IN promotional_code VARCHAR(50),
    IN items JSON  -- Array of {product_id, quantity, customization}
)
BEGIN
    DECLARE order_id BIGINT;
    DECLARE total_amount DECIMAL(12,2) DEFAULT 0;
    DECLARE discount_amount DECIMAL(12,2) DEFAULT 0;
    DECLARE tax_amount DECIMAL(12,2) DEFAULT 0;
    DECLARE shipping_cost DECIMAL(8,2) DEFAULT 0;
    DECLARE inventory_reserved BOOLEAN DEFAULT FALSE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        -- Restore reserved inventory if order fails
        IF inventory_reserved THEN
            CALL RestoreInventoryReservations(order_id);
        END IF;
        -- Log order failure for analysis (triggers fsync)
        INSERT INTO order_failures (customer_id, failure_time, items_json, error_reason)
        VALUES (customer_id, NOW(6), items, CONCAT('Order processing failed: ', SQLERRM));
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 1. Create order header (WRITE - triggers fsync)
    INSERT INTO orders (
        customer_id, order_status, order_date, shipping_address_id, 
        payment_method_id, promotional_code
    ) VALUES (
        customer_id, 'PROCESSING', NOW(6), shipping_address_id, 
        payment_method_id, promotional_code
    );
    SET order_id = LAST_INSERT_ID();
    
    -- 2. Process each item in the order
    SET @item_index = 0;
    WHILE @item_index < JSON_LENGTH(items) DO
        SET @current_item = JSON_EXTRACT(items, CONCAT('$[', @item_index, ']'));
        SET @product_id = JSON_UNQUOTE(JSON_EXTRACT(@current_item, '$.product_id'));
        SET @quantity = JSON_UNQUOTE(JSON_EXTRACT(@current_item, '$.quantity'));
        SET @customization = JSON_UNQUOTE(JSON_EXTRACT(@current_item, '$.customization'));
        
        -- 2a. Lock product for inventory check (READ with row lock)
        SELECT price, stock_quantity, weight, category_id 
        INTO @unit_price, @available_stock, @item_weight, @category_id
        FROM products 
        WHERE product_id = @product_id FOR UPDATE;
        
        IF @available_stock < @quantity THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = CONCAT('Insufficient stock for product ', @product_id);
        END IF;
        
        -- 2b. Reserve inventory (WRITE - triggers fsync)
        UPDATE products 
        SET stock_quantity = stock_quantity - @quantity,
            reserved_quantity = reserved_quantity + @quantity,
            last_updated = NOW(6)
        WHERE product_id = @product_id;
        
        -- 2c. Create order item record (WRITE - triggers fsync)
        INSERT INTO order_items (
            order_id, product_id, quantity, unit_price, customization,
            line_total, weight, category_id
        ) VALUES (
            order_id, @product_id, @quantity, @unit_price, @customization,
            @quantity * @unit_price, @item_weight * @quantity, @category_id
        );
        
        -- 2d. Log inventory movement (WRITE - triggers fsync)
        INSERT INTO inventory_movements (
            product_id, movement_type, quantity, reference_type, reference_id,
            movement_timestamp, unit_cost
        ) VALUES (
            @product_id, 'RESERVATION', -@quantity, 'ORDER', order_id,
            NOW(6), @unit_price
        );
        
        SET total_amount = total_amount + (@quantity * @unit_price);
        SET @item_index = @item_index + 1;
    END WHILE;
    
    SET inventory_reserved = TRUE;
    
    -- 3. Apply promotional discount if valid (READ + WRITE)
    IF promotional_code IS NOT NULL THEN
        SELECT discount_percentage, discount_amount, minimum_order_value
        INTO @promo_percent, @promo_amount, @min_order
        FROM promotional_codes 
        WHERE code = promotional_code AND active = 1 AND expires_at > NOW();
        
        IF @promo_percent IS NOT NULL AND total_amount >= @min_order THEN
            SET discount_amount = LEAST(total_amount * @promo_percent / 100, @promo_amount);
            
            -- Record promotion usage (WRITE - triggers fsync)
            INSERT INTO promotion_usage (
                order_id, promotional_code, discount_amount, usage_timestamp
            ) VALUES (order_id, promotional_code, discount_amount, NOW(6));
        END IF;
    END IF;
    
    -- 4. Calculate tax and shipping (READ operations for tax tables)
    CALL CalculateOrderTax(order_id, shipping_address_id, total_amount, tax_amount);
    CALL CalculateShippingCost(order_id, shipping_address_id, shipping_cost);
    
    -- 5. Update order totals (WRITE - triggers fsync)
    UPDATE orders 
    SET subtotal = total_amount,
        discount_amount = discount_amount,
        tax_amount = tax_amount,
        shipping_cost = shipping_cost,
        total_amount = total_amount - discount_amount + tax_amount + shipping_cost,
        last_updated = NOW(6)
    WHERE order_id = order_id;
    
    -- 6. Process payment authorization (WRITE - triggers fsync)
    INSERT INTO payment_transactions (
        order_id, payment_method_id, transaction_type, amount,
        transaction_timestamp, status, processor_reference
    ) VALUES (
        order_id, payment_method_id, 'AUTHORIZATION', 
        total_amount - discount_amount + tax_amount + shipping_cost,
        NOW(6), 'PENDING', UUID()
    );
    
    -- 7. Create fulfillment workflow (WRITE - triggers fsync)
    INSERT INTO fulfillment_tasks (
        order_id, task_type, priority, warehouse_id, created_at, due_date
    ) VALUES (
        order_id, 'PICK_AND_PACK', 
        CASE WHEN customer_id IN (SELECT customer_id FROM premium_customers) THEN 1 ELSE 2 END,
        (SELECT warehouse_id FROM warehouse_inventory WHERE product_id = @product_id LIMIT 1),
        NOW(6), DATE_ADD(NOW(), INTERVAL 1 DAY)
    );
    
    -- 8. Update customer metrics (WRITE - triggers fsync)
    INSERT INTO customer_order_metrics (
        customer_id, order_count, total_spent, last_order_date
    ) VALUES (
        customer_id, 1, total_amount - discount_amount + tax_amount + shipping_cost, NOW(6)
    ) ON DUPLICATE KEY UPDATE
        order_count = order_count + 1,
        total_spent = total_spent + VALUES(total_spent),
        last_order_date = VALUES(last_order_date);
    
    -- 9. Analytics and reporting (WRITE - triggers fsync)
    INSERT INTO order_analytics (
        order_id, customer_segment, order_value_bucket, item_count,
        processing_time_ms, order_timestamp
    ) VALUES (
        order_id, 
        CASE 
            WHEN total_amount > 500 THEN 'HIGH_VALUE'
            WHEN total_amount > 100 THEN 'MEDIUM_VALUE'
            ELSE 'LOW_VALUE'
        END,
        FLOOR(total_amount / 50) * 50,  -- $50 buckets
        JSON_LENGTH(items),
        TIMESTAMPDIFF(MICROSECOND, @transaction_start, NOW(6)) / 1000,
        NOW(6)
    );
    
    COMMIT; -- Final transaction log fsync
    
    SELECT order_id, total_amount - discount_amount + tax_amount + shipping_cost AS final_total;
END$$

-- Performance Analysis:
-- Fsync operations per order: 8-15 (depending on item count and promotions)
-- Average: ~12 fsync operations per order

-- Server 1 E-commerce Performance:
-- 40,473 fsync ops/sec ÷ 12 ops/order = 3,372 orders/second theoretical maximum
-- Real-world with payment processing delays: 1,500-2,000 orders/second sustainable
-- Order processing latency: <10ms average, <25ms 99th percentile
-- Daily order capacity: ~150 million orders/day
-- Peak holiday traffic: Can handle 5,000+ orders/second bursts
-- Suitable for: Amazon, eBay, major e-commerce platforms, flash sales

-- Server 9 E-commerce Performance:
-- 83 fsync ops/sec ÷ 12 ops/order = 6 orders/second theoretical maximum
-- Real-world: 2-4 orders/second maximum
-- Order processing latency: 3000ms+ average, >10 seconds 99th percentile
-- Daily order capacity: ~20,000 orders/day maximum
-- Peak holiday traffic: System would collapse under any significant load
-- Suitable for: Only very small online stores with <100 orders/day
-- Customer experience: Unacceptable delays, frequent timeouts, lost sales
```

#### **PostgreSQL Write-Ahead Logging Deep Analysis**

**🔍 Laymen Explanation:**
PostgreSQL keeps a detailed journal (Write-Ahead Log) of every change before applying it to the main database. Think of it like a detailed diary that records every action before updating the main records. If something goes wrong, the system can replay the diary to restore everything. The fsync performance determines how quickly each diary entry can be written securely.

**🔧 Technical Implementation - Production PostgreSQL Configuration:**

```postgresql
-- Server 1 (40,473 fsync ops/sec) - Enterprise PostgreSQL Configuration:

-- WAL Configuration for High-Performance Storage
wal_level = replica                              # Enable replication and archiving
wal_sync_method = fdatasync                      # Most efficient on Linux (matches test)
synchronous_commit = on                          # Full durability guarantee
wal_compression = lz4                            # Fast compression for WAL records
wal_buffers = 64MB                              # Large WAL buffer for batching
wal_writer_delay = 100ms                         # Frequent WAL writes
wal_writer_flush_after = 2MB                     # Flush after 2MB of WAL

-- Checkpoint Configuration
checkpoint_timeout = 5min                        # Frequent checkpoints (fast storage can handle)
checkpoint_completion_target = 0.9               # Spread checkpoint I/O over 90% of interval
max_wal_size = 8GB                              # Large WAL for smooth operation
min_wal_size = 2GB                              # Substantial minimum
checkpoint_flush_after = 512kB                   # Incremental checkpoint flushing

-- Background Writer Configuration
bgwriter_delay = 100ms                          # Frequent background writes
bgwriter_lru_maxpages = 1000                    # Aggressive LRU page writing
bgwriter_lru_multiplier = 10.0                  # High multiplier for busy systems
bgwriter_flush_after = 512kB                    # Small flush threshold for SSD

-- I/O and Memory Configuration
shared_buffers = 64GB                           # Assume 256GB RAM server
effective_cache_size = 192GB                    # OS cache + shared_buffers
random_page_cost = 1.1                          # SSD-optimized cost model
effective_io_concurrency = 300                  # High concurrency for NVMe
maintenance_work_mem = 4GB                      # Large maintenance operations
work_mem = 256MB                                # Per-query work memory

-- Connection and Query Configuration
max_connections = 1000                          # High connection limit
max_prepared_transactions = 1000                # For distributed transactions

-- Expected Performance Characteristics:
-- Transaction throughput: 25,000-35,000 TPS sustained
-- WAL write latency: <1ms average, <3ms 99th percentile
-- Checkpoint impact: Minimal user-visible impact
-- Replication lag: <50ms under normal load
-- Recovery time: 1-3 minutes for typical workloads
-- Concurrent connections: 800+ active connections sustainable
-- Suitable for: Enterprise applications, large-scale web services, data warehouses

-- Server 9 (83 fsync ops/sec) - Survival PostgreSQL Configuration:

-- Conservative WAL Configuration
wal_level = minimal                              # Disable replication to reduce overhead
wal_sync_method = open_sync                      # Sometimes faster on slow storage
synchronous_commit = off                         # Sacrifice durability for performance
wal_compression = off                            # Disable compression to reduce CPU load
wal_buffers = 8MB                               # Small buffer to reduce flush impact
wal_writer_delay = 30s                          # Infrequent WAL writes
wal_writer_flush_after = 0                      # Disable flush-ahead

-- Conservative Checkpoint Configuration
checkpoint_timeout = 45min                      # Very infrequent checkpoints
checkpoint_completion_target = 0.2              # Complete checkpoints quickly
max_wal_size = 512MB                           # Small WAL to limit checkpoint burden
min_wal_size = 128MB                           # Minimal WAL size
checkpoint_flush_after = 0                     # Disable incremental flushing

-- Gentle Background Writer Configuration
bgwriter_delay = 10s                           # Infrequent background writes
bgwriter_lru_maxpages = 50                     # Very conservative page writing
bgwriter_lru_multiplier = 1.0                 # Minimal multiplier
bgwriter_flush_after = 0                      # Disable incremental flushing

-- Restricted I/O and Memory Configuration
shared_buffers = 2GB                           # Small buffer pool
effective_cache_size = 4GB                     # Conservative cache estimate
random_page_cost = 8.0                         # Traditional HDD cost model
effective_io_concurrency = 1                   # Minimal concurrency
maintenance_work_mem = 256MB                   # Small maintenance operations
work_mem = 32MB                                # Limited per-query memory

-- Restricted Connection Configuration
max_connections = 50                            # Very limited connections
max_prepared_transactions = 0                   # Disable prepared transactions

-- Expected Performance Characteristics:
-- Transaction throughput: 40-60 TPS maximum
-- WAL write latency: 15ms+ average, >100ms 99th percentile
-- Checkpoint impact: Severe user-visible stalls (30+ seconds)
-- Replication: Not viable due to performance impact
-- Recovery time: 30+ minutes for typical workloads
-- Concurrent connections: 10-20 active connections maximum
-- Suitable for: Development/testing only, very small applications
```

**Real-World PostgreSQL Workload - Analytics Platform:**
```sql
-- Large-scale analytics platform (data warehouse scenario):
CREATE OR REPLACE FUNCTION process_analytics_batch(
    batch_size INTEGER DEFAULT 10000
) RETURNS TABLE(
    batch_id BIGINT,
    records_processed INTEGER,
    processing_time_ms BIGINT,
    wal_operations_estimated INTEGER
) AS $$
DECLARE
    start_time TIMESTAMPTZ := clock_timestamp();
    end_time TIMESTAMPTZ;
    current_batch_id BIGINT;
    records_count INTEGER := 0;
    wal_ops INTEGER := 0;
BEGIN
    -- Create new batch record (WAL write)
    INSERT INTO analytics_batches (start_time, status)
    VALUES (start_time, 'PROCESSING')
    RETURNING id INTO current_batch_id;
    wal_ops := wal_ops + 1;
    
    -- Process user activity events
    WITH activity_aggregates AS (
        SELECT 
            user_id,
            event_date,
            COUNT(*) as event_count,
            COUNT(DISTINCT session_id) as session_count,
            SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) as page_views,
            SUM(CASE WHEN event_type = 'purchase' THEN event_value ELSE 0 END) as purchase_value,
            MAX(event_timestamp) as last_activity
        FROM user_events 
        WHERE processed = false
        AND event_timestamp >= NOW() - INTERVAL '1 hour'
        GROUP BY user_id, event_date
        LIMIT batch_size
    )
    INSERT INTO user_daily_stats (
        user_id, activity_date, event_count, session_count, 
        page_views, purchase_value, last_activity, batch_id
    )
    SELECT 
        user_id, event_date, event_count, session_count,
        page_views, purchase_value, last_activity, current_batch_id
    FROM activity_aggregates
    ON CONFLICT (user_id, activity_date) 
    DO UPDATE SET
        event_count = user_daily_stats.event_count + EXCLUDED.event_count,
        session_count = user_daily_stats.session_count + EXCLUDED.session_count,
        page_views = user_daily_stats.page_views + EXCLUDED.page_views,
        purchase_value = user_daily_stats.purchase_value + EXCLUDED.purchase_value,
        last_activity = GREATEST(user_daily_stats.last_activity, EXCLUDED.last_activity),
        updated_at = clock_timestamp();
    
    GET DIAGNOSTICS records_count = ROW_COUNT;
    wal_ops := wal_ops + (records_count / 100);  -- Estimate WAL operations
    
    -- Update product performance metrics (WAL write)
    WITH product_metrics AS (
        SELECT 
            product_id,
            COUNT(*) as view_count,
            COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) as purchase_count,
            SUM(CASE WHEN event_type = 'purchase' THEN event_value ELSE 0 END) as revenue
        FROM user_events 
        WHERE processed = false
        AND event_type IN ('product_view', 'purchase')
        AND event_timestamp >= NOW() - INTERVAL '1 hour'
        GROUP BY product_id
    )
    INSERT INTO product_hourly_stats (
        product_id, hour_start, view_count, purchase_count, 
        revenue, conversion_rate, batch_id
    )
    SELECT 
        product_id,
        date_trunc('hour', NOW()),
        view_count,
        purchase_count,
        revenue,
        CASE WHEN view_count > 0 THEN purchase_count::DECIMAL / view_count ELSE 0 END,
        current_batch_id
    FROM product_metrics
    ON CONFLICT (product_id, hour_start)
    DO UPDATE SET
        view_count = product_hourly_stats.view_count + EXCLUDED.view_count,
        purchase_count = product_hourly_stats.purchase_count + EXCLUDED.purchase_count,
        revenue = product_hourly_stats.revenue + EXCLUDED.revenue,
        conversion_rate = CASE 
            WHEN (product_hourly_stats.view_count + EXCLUDED.view_count) > 0 
            THEN (product_hourly_stats.purchase_count + EXCLUDED.purchase_count)::DECIMAL / 
                 (product_hourly_stats.view_count + EXCLUDED.view_count)
            ELSE 0 
        END,
        updated_at = clock_timestamp();
    
    wal_ops := wal_ops + (records_count / 200);  -- Estimate additional WAL operations
    
    -- Create real-time dashboard updates (WAL write)
    INSERT INTO dashboard_metrics (
        metric_name, metric_value, timestamp, batch_id
    ) VALUES 
    ('active_users_last_hour', 
     (SELECT COUNT(DISTINCT user_id) FROM user_events WHERE event_timestamp >= NOW() - INTERVAL '1 hour'), 
     clock_timestamp(), current_batch_id),
    ('total_revenue_last_hour',
     (SELECT COALESCE(SUM(event_value), 0) FROM user_events WHERE event_type = 'purchase' AND event_timestamp >= NOW() - INTERVAL '1 hour'),
     clock_timestamp(), current_batch_id),
    ('page_views_last_hour',
     (SELECT COUNT(*) FROM user_events WHERE event_type = 'page_view' AND event_timestamp >= NOW() - INTERVAL '1 hour'),
     clock_timestamp(), current_batch_id);
    
    wal_ops := wal_ops + 3;
    
    -- Mark events as processed (WAL write)
    UPDATE user_events 
    SET processed = true, processed_batch_id = current_batch_id
    WHERE processed = false 
    AND event_timestamp >= NOW() - INTERVAL '1 hour'
    AND user_id IN (
        SELECT DISTINCT user_id 
        FROM user_daily_stats 
        WHERE batch_id = current_batch_id
    );
    
    wal_ops := wal_ops + (records_count / 100);
    
    -- Complete batch record (WAL write)
    UPDATE analytics_batches 
    SET end_time = clock_timestamp(),
        status = 'COMPLETED',
        records_processed = records_count
    WHERE id = current_batch_id;
    wal_ops := wal_ops + 1;
    
    end_time := clock_timestamp();
    
    RETURN QUERY SELECT 
        current_batch_id,
        records_count,
        EXTRACT(EPOCH FROM (end_time - start_time)) * 1000,
        wal_ops;
END;
$$ LANGUAGE plpgsql;

-- Performance Analysis:
-- WAL operations per batch: ~50-100 (depending on batch size and data volume)

-- Server 1 Analytics Performance:
-- 40,473 fsync ops/sec ÷ 75 avg ops/batch = 539 batches/second
-- 10,000 records/batch × 539 batches/sec = 5.39 million records/second processing
-- Hourly data processing: 19.4 billion records/hour
-- Real-time analytics: Sub-second dashboard updates
-- Suitable for: Google Analytics scale, large-scale IoT platforms, financial market data

-- Server 9 Analytics Performance:
-- 83 fsync ops/sec ÷ 75 avg ops/batch = 1.1 batches/second
-- 10,000 records/batch × 1.1 batches/sec = 11,000 records/second processing
-- Hourly data processing: 39.6 million records/hour
-- Real-time analytics: 45+ second delays for dashboard updates
-- Suitable for: Small business analytics only, batch processing with significant delays
```

### **Web Server Implications - Production Scale**

#### **High-Performance Session Management**

**🔍 Laymen Explanation:**
Web applications need to remember information about each user as they navigate the site—like items in their shopping cart, their login status, or their preferences. This information is stored in "sessions." Every time a user does something important (login, add to cart, make a purchase), the web server needs to update and save this session information to disk so it won't be lost. Fast fsync means users don't experience delays when their actions need to be saved.

**🔧 Technical Implementation - Enterprise Session Architecture:**

```python
# Production-grade session management system
import asyncio
import aiofiles
import json
import time
import hashlib
import os
from typing import Dict, Any, Optional, List
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
import redis
import logging

@dataclass
class SessionData:
    session_id: str
    user_id: Optional[str]
    created_at: float
    last_activity: float
    data: Dict[str, Any]
    security_context: Dict[str, Any]
    persistence_level: str  # 'memory', 'disk', 'distributed'

class HighPerformanceSessionManager:
    """Enterprise-grade session manager optimized for different storage performance levels"""
    
    def __init__(self, storage_config: Dict[str, Any]):
        self.storage_config = storage_config
        self.performance_profile = storage_config.get('performance_profile', 'unknown')
        self.session_cache = {}  # In-memory cache
        self.redis_client = None
        self.fsync_operations = 0
        self.session_operations = 0
        
        # Configure based on storage performance
        if self.performance_profile == 'server_1':  # High-performance storage
            self.batch_size = 100
            self.flush_interval = 0.1  # 100ms
            self.persistence_strategy = 'immediate'
            self.cache_size_limit = 1000000  # 1M sessions in memory
        elif self.performance_profile == 'server_6':  # Poor storage
            self.batch_size = 10
            self.flush_interval = 5.0  # 5 seconds
            self.persistence_strategy = 'batched'
            self.cache_size_limit = 10000  # 10K sessions in memory
        else:
            self.batch_size = 50
            self.flush_interval = 1.0
            self.persistence_strategy = 'mixed'
            self.cache_size_limit = 100000
    
    async def create_session(self, user_id: Optional[str] = None, 
                           initial_data: Optional[Dict[str, Any]] = None) -> SessionData:
        """Create a new session with performance-optimized persistence"""
        operation_start = time.perf_counter()
        
        session = SessionData(
            session_id=self._generate_session_id(),
            user_id=user_id,
            created_at=time.time(),
            last_activity=time.time(),
            data=initial_data or {},
            security_context={
                'ip_address': None,  # To be filled by web framework
                'user_agent': None,
                'csrf_token': self._generate_csrf_token(),
                'login_attempts': 0
            },
            persistence_level='disk' if user_id else 'memory'
        )
        
        # Store in memory cache
        self.session_cache[session.session_id] = session
        
        # Persist based on strategy and performance profile
        if self.persistence_strategy == 'immediate' or session.persistence_level == 'disk':
            await self._persist_session_immediate(session)
        else:
            await self._queue_for_batch_persistence(session)
        
        operation_time = (time.perf_counter() - operation_start) * 1000
        self.session_operations += 1
        
        return session
    
    async def update_session(self, session_id: str, updates: Dict[str, Any]) -> Optional[SessionData]:
        """Update session with optimized persistence based on change criticality"""
        operation_start = time.perf_counter()
        
        # Get session from cache or load from storage
        session = self.session_cache.get(session_id)
        if not session:
            session = await self._load_session_from_storage(session_id)
            if not session:
                return None
        
        # Determine criticality of changes
        critical_changes = self._assess_change_criticality(updates)
        
        # Apply updates
        session.data.update(updates)
        session.last_activity = time.time()
        
        # Update cache
        self.session_cache[session_id] = session
        
        # Persist based on criticality and performance profile
        if critical_changes or self.persistence_strategy == 'immediate':
            await self._persist_session_immediate(session)
        else:
            await self._queue_for_batch_persistence(session)
        
        operation_time = (time.perf_counter() - operation_start) * 1000
        self.session_operations += 1
        
        return session
    
    async def handle_user_login(self, session_id: str, user_credentials: Dict[str, str]) -> Dict[str, Any]:
        """Handle user login with security logging and session management"""
        operation_start = time.perf_counter()
        
        session = await self.get_session(session_id)
        if not session:
            session = await self.create_session()
        
        # Authenticate user (placeholder - would integrate with auth system)
        auth_result = await self._authenticate_user(user_credentials)
        
        if auth_result['success']:
            # Update session with user info
            await self.update_session(session_id, {
                'user_id': auth_result['user_id'],
                'login_time': time.time(),
                'authentication_level': auth_result.get('auth_level', 1),
                'roles': auth_result.get('roles', []),
                'permissions': auth_result.get('permissions', [])
            })
            
            # Update persistence level for authenticated session
            session.persistence_level = 'disk'
            session.user_id = auth_result['user_id']
            
            # Log successful login (triggers fsync for security audit)
            await self._security_log('LOGIN_SUCCESS', {
                'session_id': session_id,
                'user_id': auth_result['user_id'],
                'timestamp': time.time(),
                'ip_address': session.security_context.get('ip_address'),
                'user_agent': session.security_context.get('user_agent')
            })
            
        else:
            # Log failed login attempt (triggers fsync for security)
            await self._security_log('LOGIN_FAILED', {
                'session_id': session_id,
                'username': user_credentials.get('username'),
                'timestamp': time.time(),
                'failure_reason': auth_result.get('reason'),
                'ip_address': session.security_context.get('ip_address')
            })
            
            # Update login attempt counter
            session.security_context['login_attempts'] += 1
            await self.update_session(session_id, {})  # Trigger persistence
        
        operation_time = (time.perf_counter() - operation_start) * 1000
        
        return {
            'success': auth_result['success'],
            'session_id': session_id,
            'operation_time_ms': operation_time,
            'user_id': auth_result.get('user_id') if auth_result['success'] else None
        }
    
    async def handle_shopping_cart_operations(self, session_id: str, operation: str, 
                                            item_data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle e-commerce shopping cart operations with optimized persistence"""
        operation_start = time.perf_counter()
        
        session = await self.get_session(session_id)
        if not session:
            return {'error': 'Invalid session'}
        
        cart = session.data.get('shopping_cart', {
            'items': [],
            'total_value': 0.0,
            'last_modified': time.time()
        })
        
        if operation == 'add_item':
            # Add item to cart
            cart['items'].append({
                'product_id': item_data['product_id'],
                'quantity': item_data['quantity'],
                'price': item_data['price'],
                'added_at': time.time()
            })
            cart['total_value'] += item_data['price'] * item_data['quantity']
            
            # Log cart addition for analytics (may trigger fsync)
            await self._analytics_log('CART_ADD_ITEM', {
                'session_id': session_id,
                'user_id': session.user_id,
                'product_id': item_data['product_id'],
                'quantity': item_data['quantity'],
                'cart_value': cart['total_value']
            })
            
        elif operation == 'remove_item':
            # Remove item from cart
            cart['items'] = [item for item in cart['items'] 
                           if item['product_id'] != item_data['product_id']]
            cart['total_value'] = sum(item['price'] * item['quantity'] for item in cart['items'])
            
        elif operation == 'checkout':
            # Process checkout
            checkout_result = await self._process_checkout(session_id, cart)
            
            if checkout_result['success']:
                # Clear cart after successful checkout
                cart = {
                    'items': [],
                    'total_value': 0.0,
                    'last_modified': time.time()
                }
                
                # Log successful checkout (triggers fsync for order tracking)
                await self._order_log('CHECKOUT_SUCCESS', {
                    'session_id': session_id,
                    'user_id': session.user_id,
                    'order_id': checkout_result['order_id'],
                    'total_amount': checkout_result['total_amount']
                })
        
        cart['last_modified'] = time.time()
        
        # Update session with cart changes
        await self.update_session(session_id, {'shopping_cart': cart})
        
        operation_time = (time.perf_counter() - operation_start) * 1000
        
        return {
            'success': True,
            'cart': cart,
            'operation_time_ms': operation_time
        }
    
    async def _persist_session_immediate(self, session: SessionData):
        """Persist session immediately with fsync for critical data"""
        if self.performance_profile == 'server_6':
            # For poor storage, only persist critical sessions immediately
            if session.user_id is None and session.persistence_level != 'disk':
                return  # Skip non-critical sessions
        
        session_file = f"{self.storage_config['session_dir']}/{session.session_id}.json"
        
        try:
            async with aiofiles.open(session_file, 'w') as f:
                await f.write(json.dumps(asdict(session), indent=2))
                await f.flush()
                
                # Force fsync for data durability
                os.fsync(f.fileno())
                self.fsync_operations += 1
                
        except Exception as e:
            logging.error(f"Failed to persist session {session.session_id}: {e}")
    
    async def _security_log(self, event_type: str, data: Dict[str, Any]):
        """Write security events with immediate fsync"""
        log_entry = {
            'timestamp': time.time(),
            'event_type': event_type,
            'data': data,
            'checksum': hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()
        }
        
        security_log_file = f"{self.storage_config['log_dir']}/security_{datetime.now().strftime('%Y%m%d')}.log"
        
        try:
            async with aiofiles.open(security_log_file, 'a') as f:
                await f.write(json.dumps(log_entry) + '\n')
                await f.flush()
                os.fsync(f.fileno())  # Immediate fsync for security logs
                self.fsync_operations += 1
                
        except Exception as e:
            logging.error(f"Failed to write security log: {e}")
    
    async def _analytics_log(self, event_type: str, data: Dict[str, Any]):
        """Write analytics events with batched fsync for performance"""
        log_entry = {
            'timestamp': time.time(),
            'event_type': event_type,
            'data': data
        }
        
        if self.performance_profile == 'server_1':
            # High-performance storage can handle immediate analytics logging
            analytics_log_file = f"{self.storage_config['log_dir']}/analytics_{datetime.now().strftime('%Y%m%d')}.log"
            
            try:
                async with aiofiles.open(analytics_log_file, 'a') as f:
                    await f.write(json.dumps(log_entry) + '\n')
                    await f.flush()
                    os.fsync(f.fileno())
                    self.fsync_operations += 1
            except Exception as e:
                logging.error(f"Failed to write analytics log: {e}")
        else:
            # Poor storage - batch analytics events
            # (Implementation would use a queue and periodic batch writes)
            pass

# Performance Analysis for different storage profiles:

# Server 1 Session Performance (40,473 fsync ops/sec):
session_performance_server_1 = {
    'login_operations_per_second': 40473 // 3,  # 3 fsync ops per login (session + security log + auth)
    'cart_operations_per_second': 40473 // 2,   # 2 fsync ops per cart operation (session + analytics)
    'concurrent_users_supported': 500000,        # 500K active sessions in memory + disk
    'session_operation_latency': '<1ms',         # Sub-millisecond session operations
    'login_latency': '<5ms',                     # Fast login processing
    'cart_operation_latency': '<3ms',            # Quick cart updates
    'suitable_for': [
        'Major e-commerce platforms (Amazon, eBay scale)',
        'Social media applications (Facebook, Twitter scale)',
        'Enterprise SaaS platforms',
        'Real-time collaboration tools',
        'Online gaming platforms',
        'Financial services web applications'
    ],
    'peak_traffic_handling': 'Can handle Black Friday/Cyber Monday traffic',
    'security_compliance': 'Full audit trail with immediate logging',
    'user_experience': 'Instantaneous response to user actions'
}

# Server 9 Session Performance (83 fsync ops/sec):
session_performance_server_6 = {
    'login_operations_per_second': 83 // 3,      # 27 logins/second maximum
    'cart_operations_per_second': 83 // 2,       # 41 cart operations/second maximum
    'concurrent_users_supported': 1000,          # Very limited active sessions
    'session_operation_latency': '12ms+',        # Noticeable delays
    'login_latency': '150ms+',                   # Slow login processing
    'cart_operation_latency': '50ms+',           # Sluggish cart updates
    'suitable_for': [
        'Small business websites only',
        'Personal blogs with minimal interactivity',
        'Internal company tools with <100 users',
        'Development/testing environments'
    ],
    'peak_traffic_handling': 'Cannot handle any significant traffic spikes',
    'security_compliance': 'May lose audit events under load',
    'user_experience': 'Users experience delays and timeouts'
}
```

#### **Content Management and Publishing Systems**

**🔍 Laymen Explanation:**
When content creators publish articles, blog posts, or product updates on websites, the system needs to save the content, update search indexes, clear cached pages, and notify other systems. Each of these steps requires writing data safely to disk. It's like a newspaper editor who needs to save the article, update the table of contents, print new copies, and notify the distribution centers—all of which take time depending on how fast the printing press operates.

**🔧 Technical Implementation - Enterprise Content Platform:**

```python
# Enterprise content management system
import asyncio
import aiofiles
import json
import time
import hashlib
import os
from typing import Dict, Any, List, Optional
from dataclasses import dataclass, asdict
from datetime import datetime
import logging

@dataclass
class ContentItem:
    content_id: str
    title: str
    body: str
    author_id: str
    status: str  # draft, published, archived
    metadata: Dict[str, Any]
    created_at: float
    updated_at: float
    published_at: Optional[float]

class EnterpriseContentManager:
    """Production-grade content management optimized for different storage performance"""
    
    def __init__(self, storage_config: Dict[str, Any]):
        self.storage_config = storage_config
        self.performance_profile = storage_config.get('performance_profile', 'unknown')
        self.content_cache = {}
        self.search_index_queue = []
        self.cdn_invalidation_queue = []
        self.fsync_operations = 0
        self.content_operations = 0
        
        # Configure based on storage performance
        if self.performance_profile == 'server_1':
            self.enable_realtime_indexing = True
            self.enable_immediate_cdn_invalidation = True
            self.enable_full_audit_logging = True
            self.cache_invalidation_strategy = 'immediate'
            self.search_index_update_delay = 0.1  # 100ms
        else:  # server_6
            self.enable_realtime_indexing = False
            self.enable_immediate_cdn_invalidation = False
            self.enable_full_audit_logging = False
            self.cache_invalidation_strategy = 'batched'
            self.search_index_update_delay = 30.0  # 30 seconds
    
    async def publish_content(self, content_data: Dict[str, Any], author_id: str) -> Dict[str, Any]:
        """Publish content with comprehensive workflow"""
        operation_start = time.perf_counter()
        fsync_operations_start = self.fsync_operations
        
        content = ContentItem(
            content_id=self._generate_content_id(),
            title=content_data['title'],
            body=content_data['body'],
            author_id=author_id,
            status='published',
            metadata=content_data.get('metadata', {}),
            created_at=time.time(),
            updated_at=time.time(),
            published_at=time.time()
        )
        
        try:
            # 1. Save content to primary storage (triggers fsync)
            await self._persist_content(content)
            
            # 2. Update content metadata indexes (triggers fsync)
            await self._update_content_indexes(content)
            
            # 3. Generate and save content variants (triggers fsync per variant)
            variants_created = await self._generate_content_variants(content)
            
            # 4. Update search index
            if self.enable_realtime_indexing:
                await self._update_search_index_immediate(content)
            else:
                await self._queue_search_index_update(content)
            
            # 5. Invalidate related caches
            cache_operations = await self._invalidate_content_caches(content)
            
            # 6. Notify content delivery network
            if self.enable_immediate_cdn_invalidation:
                await self._invalidate_cdn_cache(content)
            else:
                await self._queue_cdn_invalidation(content)
            
            # 7. Update author statistics (triggers fsync)
            await self._update_author_stats(author_id, content)
            
            # 8. Log publishing activity
            if self.enable_full_audit_logging:
                await self._audit_log('CONTENT_PUBLISHED', {
                    'content_id': content.content_id,
                    'author_id': author_id,
                    'title': content.title,
                    'content_length': len(content.body),
                    'fsync_operations': self.fsync_operations - fsync_operations_start
                })
            
            # 9. Generate analytics events (triggers fsync)
            await self._analytics_log('CONTENT_PUBLISH', {
                'content_id': content.content_id,
                'author_id': author_id,
                'content_type': content.metadata.get('type', 'article'),
                'word_count': len(content.body.split()),
                'category': content.metadata.get('category'),
                'tags': content.metadata.get('tags', [])
            })
            
            # 10. Trigger workflow automations (triggers fsync)
            await self._trigger_publishing_workflows(content)
            
            operation_time = (time.perf_counter() - operation_start) * 1000
            total_fsync_ops = self.fsync_operations - fsync_operations_start
            self.content_operations += 1
            
            return {
                'success': True,
                'content_id': content.content_id,
                'operation_time_ms': operation_time,
                'fsync_operations': total_fsync_ops,
                'variants_created': variants_created,
                'cache_operations': cache_operations,
                'performance_rating': self._rate_publishing_performance(operation_time)
            }
            
        except Exception as e:
            # Log publishing error (triggers fsync)
            await self._error_log('CONTENT_PUBLISH_FAILED', {
                'author_id': author_id,
                'title': content_data.get('title', 'Unknown'),
                'error': str(e),
                'timestamp': time.time()
            })
            
            return {
                'success': False,
                'error': str(e),
                'operation_time_ms': (time.perf_counter() - operation_start) * 1000
            }
    
    async def bulk_publish_content(self, content_list: List[Dict[str, Any]], 
                                 author_id: str) -> Dict[str, Any]:
        """Bulk content publishing with optimized batch operations"""
        bulk_start = time.perf_counter()
        fsync_operations_start = self.fsync_operations
        
        published_content = []
        failed_content = []
        
        if self.performance_profile == 'server_1':
            # High-performance storage: Process in parallel
            tasks = [self.publish_content(content_data, author_id) for content_data in content_list]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
            for i, result in enumerate(results):
                if isinstance(result, Exception):
                    failed_content.append({'index': i, 'error': str(result)})
                elif result.get('success'):
                    published_content.append(result)
                else:
                    failed_content.append({'index': i, 'error': result.get('error')})
        
        else:  # server_6
            # Poor storage: Process sequentially with delays
            for i, content_data in enumerate(content_list):
                try:
                    result = await self.publish_content(content_data, author_id)
                    if result.get('success'):
                        published_content.append(result)
                    else:
                        failed_content.append({'index': i, 'error': result.get('error')})
                    
                    # Add delay between operations for poor storage
                    if i < len(content_list) - 1:
                        await asyncio.sleep(1.0)  # 1 second delay
                        
                except Exception as e:
                    failed_content.append({'index': i, 'error': str(e)})
        
        # Batch operations summary (triggers fsync)
        await self._audit_log('BULK_CONTENT_PUBLISHED', {
            'author_id': author_id,
            'total_items': len(content_list),
            'successful': len(published_content),
            'failed': len(failed_content),
            'total_fsync_operations': self.fsync_operations - fsync_operations_start,
            'bulk_processing_time_ms': (time.perf_counter() - bulk_start) * 1000
        })
        
        return {
            'published_count': len(published_content),
            'failed_count': len(failed_content),
            'total_time_ms': (time.perf_counter() - bulk_start) * 1000,
            'total_fsync_operations': self.fsync_operations - fsync_operations_start,
            'average_time_per_item': ((time.perf_counter() - bulk_start) * 1000) / len(content_list),
            'published_content': published_content,
            'failed_content': failed_content
        }
    
    async def _persist_content(self, content: ContentItem):
        """Persist content with immediate fsync"""
        content_file = f"{self.storage_config['content_dir']}/{content.content_id}.json"
        
        async with aiofiles.open(content_file, 'w') as f:
            await f.write(json.dumps(asdict(content), indent=2))
            await f.flush()
            os.fsync(f.fileno())
            self.fsync_operations += 1
    
    async def _update_content_indexes(self, content: ContentItem):
        """Update content indexes and metadata"""
        # Title index (triggers fsync)
        title_index_file = f"{self.storage_config['index_dir']}/titles.json"
        await self._update_index_file(title_index_file, content.content_id, {
            'title': content.title,
            'author_id': content.author_id,
            'published_at': content.published_at
        })
        
        # Category index (triggers fsync)
        if 'category' in content.metadata:
            category_index_file = f"{self.storage_config['index_dir']}/categories/{content.metadata['category']}.json"
            await self._update_index_file(category_index_file, content.content_id, {
                'title': content.title,
                'published_at': content.published_at
            })
        
        # Tag indexes (triggers fsync per tag)
        if 'tags' in content.metadata:
            for tag in content.metadata['tags']:
                tag_index_file = f"{self.storage_config['index_dir']}/tags/{tag}.json"
                await self._update_index_file(tag_index_file, content.content_id, {
                    'title': content.title,
                    'published_at': content.published_at
                })
    
    async def _generate_content_variants(self, content: ContentItem) -> int:
        """Generate content variants (mobile, AMP, etc.)"""
        variants_created = 0
        
        if self.performance_profile == 'server_1':
            # Generate multiple variants for high-performance storage
            variants = ['mobile', 'amp', 'excerpt', 'social_preview']
            
            for variant_type in variants:
                variant_content = self._generate_variant(content, variant_type)
                variant_file = f"{self.storage_config['variants_dir']}/{content.content_id}_{variant_type}.json"
                
                async with aiofiles.open(variant_file, 'w') as f:
                    await f.write(json.dumps(variant_content, indent=2))
                    await f.flush()
                    os.fsync(f.fileno())
                    self.fsync_operations += 1
                    variants_created += 1
        
        else:  # server_6
            # Only generate essential variant for poor storage
            variant_content = self._generate_variant(content, 'excerpt')
            variant_file = f"{self.storage_config['variants_dir']}/{content.content_id}_excerpt.json"
            
            async with aiofiles.open(variant_file, 'w') as f:
                await f.write(json.dumps(variant_content, indent=2))
                await f.flush()
                os.fsync(f.fileno())
                self.fsync_operations += 1
                variants_created = 1
        
        return variants_created
    
    async def _invalidate_content_caches(self, content: ContentItem) -> int:
        """Invalidate related caches"""
        cache_operations = 0
        
        cache_keys_to_invalidate = [
            f"content_{content.content_id}",
            f"author_{content.author_id}_content",
            "homepage_recent_content",
            "sitemap_content_list"
        ]
        
        # Add category-specific cache keys
        if 'category' in content.metadata:
            cache_keys_to_invalidate.append(f"category_{content.metadata['category']}_content")
        
        # Add tag-specific cache keys
        if 'tags' in content.metadata:
            for tag in content.metadata['tags']:
                cache_keys_to_invalidate.append(f"tag_{tag}_content")
        
        if self.cache_invalidation_strategy == 'immediate':
            # Immediate cache invalidation (triggers fsync per cache operation)
            for cache_key in cache_keys_to_invalidate:
                await self._invalidate_cache_key(cache_key)
                cache_operations += 1
        else:
            # Batch cache invalidation
            cache_invalidation_file = f"{self.storage_config['cache_dir']}/invalidation_queue.json"
            await self._append_to_file(cache_invalidation_file, {
                'cache_keys': cache_keys_to_invalidate,
                'timestamp': time.time(),
                'content_id': content.content_id
            })
            cache_operations = 1
        
        return cache_operations
    
    async def _update_search_index_immediate(self, content: ContentItem):
        """Update search index immediately (triggers fsync)"""
        search_document = {
            'id': content.content_id,
            'title': content.title,
            'body': content.body,
            'author_id': content.author_id,
            'published_at': content.published_at,
            'metadata': content.metadata
        }
        
        search_index_file = f"{self.storage_config['search_dir']}/documents/{content.content_id}.json"
        
        async with aiofiles.open(search_index_file, 'w') as f:
            await f.write(json.dumps(search_document, indent=2))
            await f.flush()
            os.fsync(f.fileno())
            self.fsync_operations += 1
        
        # Update search index metadata (triggers fsync)
        index_metadata_file = f"{self.storage_config['search_dir']}/index_metadata.json"
        await self._update_index_file(index_metadata_file, content.content_id, {
            'indexed_at': time.time(),
            'document_size': len(json.dumps(search_document))
        })

# Performance Analysis for Content Management:

# Server 1 Content Performance (40,473 fsync ops/sec):
content_performance_server_1 = {
    'single_article_publish_time': '5-10ms',
    'articles_published_per_second': 40473 // 15,  # ~2,698 articles/second (15 fsync ops per publish)
    'bulk_publish_capability': '10,000 articles in 3.7 seconds',
    'concurrent_authors_supported': 1000,  # 1000 authors publishing simultaneously
    'content_variants_generated': 4,  # mobile, AMP, excerpt, social_preview
    'search_index_update': 'Real-time (<100ms)',
    'cache_invalidation': 'Immediate',
    'cdn_propagation': 'Immediate',
    'audit_logging': 'Complete with full trail',
    'suitable_for': [
        'Major news organizations (CNN, BBC, Reuters)',
        'Large-scale blogging platforms (Medium, WordPress.com)',
        'Enterprise CMS (corporate websites, intranets)',
        'E-commerce platforms (product catalogs)',
        'Educational platforms (course content)',
        'Documentation platforms (technical docs)'
    ],
    'peak_publishing_events': 'Can handle breaking news with thousands of simultaneous updates',
    'editorial_workflow': 'Real-time collaboration with instant publishing',
    'user_experience': 'Content appears live immediately after publish'
}

# Server 9 Content Performance (83 fsync ops/sec):
content_performance_server_6 = {
    'single_article_publish_time': '3-5 seconds',
    'articles_published_per_second': 83 // 15,  # ~5 articles/second (15 fsync ops per publish)
    'bulk_publish_capability': '10 articles in 30+ seconds',
    'concurrent_authors_supported': 2,  # Only 2 authors can publish simultaneously
    'content_variants_generated': 1,  # Only excerpt variant
    'search_index_update': 'Delayed (30+ seconds)',
    'cache_invalidation': 'Batched (minutes delay)',
    'cdn_propagation': 'Delayed',
    'audit_logging': 'Limited to essential events only',
    'suitable_for': [
        'Small personal blogs',
        'Internal company newsletters',
        'Development/testing environments',
        'Very small business websites'
    ],
    'peak_publishing_events': 'Cannot handle any significant publishing volume',
    'editorial_workflow': 'Sequential publishing with long delays',
    'user_experience': 'Content may take minutes to appear after publish'
}
```