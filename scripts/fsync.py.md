## 💾 Why Drive `fsync()` Performance Matters

When applications save data, they often rely on a system call called `fsync()` to ensure that data is physically written to the storage device. This is crucial for data integrity, especially in databases where losing recent transactions can be catastrophic.

**Key Points:**

* **Data Durability:** `fsync()` ensures that data is safely stored on disk, protecting against data loss during unexpected events like power failures.

* **Performance Impact:** The speed of `fsync()` operations varies across storage devices. Traditional hard drives (HDDs) have slower `fsync()` times compared to solid-state drives (SSDs), affecting how quickly applications can confirm data is saved.

* **Database Operations:** In databases like MySQL, `fsync()` is used to write transaction logs and data files. Slow `fsync()` performance can lead to increased latency for transactions, affecting overall database responsiveness.

* **Storage Choices:** Choosing storage with better `fsync()` performance (like enterprise-grade SSDs) can significantly improve application and database performance.

Understanding and optimizing `fsync()` performance is essential for building reliable and efficient systems.

## Examples

Example results for `fsync.py` to test various dedicated servers' drives and their fsync performance as outlined at https://www.percona.com/blog/fsync-performance-storage-devices/. You can see that datacenter or enterprise NVMe/SATA SSD have much faster fsync performance that regularly consumer SATA SSD or consumer NVMe drives.

| Server # | CPU | OS | Kernel | Storage | Operations/sec | Avg time per op (ms) |
|----------|-----|-------|--------|---------|---------------|----------------------|
| 1 | Intel Xeon E-2276G | AlmaLinux 8.10 | 4.18.0-425.19.2.el8_7.x86_64 | 2x 960GB NVMe RAID 1 (Samsung PM983 + Kingston DC1500M) | 40,473.06 | 0.025 |
| 2 | Intel Core i7-4790K | AlmaLinux 9.4 | 5.14.0-284.11.1.el9_2.x86_64 | 240GB Samsung PM863 SATA SSD | 25,394.32 | 0.039 |
| 4 | Intel Xeon E3-1270 v6 | Rocky Linux 9.5 | 5.14.0-503.14.1.el9_5.x86_64 | 2x 450GB Intel DC P3520 NVMe RAID 1 | 2,026.88 | 0.493 |
| 5 | Intel Xeon E-2236 | CentOS Linux 7 | 3.10.0-1160.118.1.el7.x86_64 | 512GB Kingston KC3000 NVMe | 1,001.50 | 0.999 |
| 3 | AMD Ryzen 9 5950X | AlmaLinux 9.5 | 5.14.0-503.23.2.el9_5.x86_64 | 512GB Samsung 850 Pro SATA SSD | 442.55 | 2.260 |

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
OS:            AlmaLinux 9.4 (Seafoam Ocelot)
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
nvme0n1  KINGSTON  SKC3000S1024G  50026B7686B341DD  disk
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

```bash

```

```bash

```

```bash

```

```bash

```