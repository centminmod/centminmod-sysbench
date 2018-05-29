# sysbench contents

* [sysbench.sh tool](#sysbenchsh-tool)
* [sysbench.sh install](#sysbench-install)
* [sysbench.sh update](#sysbench-update)
* [sysbench.sh usage](#sysbench-usage)
* [sysbench cpu benchmark](#sysbench-cpu)
* [sysbench memory benchmark](#sysbench-memory)
* [sysbench fileio benchmark](#sysbench-fileio)
* [sysbench mysql read/write OLTP legacy benchmark](#sysbench-mysql-readwrite-oltp)
* [sysbench mysql read only OLTP legacy benchmark](#sysbench-mysql-read-only-oltp)
* [sysbench mysql INSERT legacy benchmark](#sysbench-mysql-insert)
* [sysbench mysql UPDATE INDEX legacy benchmark](#sysbench-mysql-update-index)
* [sysbench mysql UPDATE NON-INDEX legacy benchmark](#sysbench-mysql-update-nonindex)
* [sysbench mysql OLTP read/write new benchmark](#sysbench-mysql-oltp-new-readwrite)
* [sysbench mysql OLTP read only new benchmark](#sysbench-mysql-oltp-new-read-only)
* [sysbench mysql OLTP write only new benchmark](#sysbench-mysql-oltp-new-write-only)
* [sysbench mysql OLTP POINT SELECT new benchmark](#sysbench-mysql-oltp-new-point-select)

# sysbench.sh tool

`sysbench.sh` benchmark tool utilising [sysbench](https://github.com/akopytov/sysbench). The `sysbench.sh` script is written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing. Results are displayed in 3 formats, standard, github markdown and CSV comma separated.

```
sysbench --version
sysbench 1.0.14
```

sysbench will switch to using jemalloc memory allocator instead of system default glibc if available

```
lsof | grep jemalloc | egrep -v 'nginx|mysqld|redis'
sysbench    709            root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   711      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   712      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   713      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   714      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   717      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   718      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   720      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
sysbench    709   723      root  mem       REG                9,1    212096     530496 /usr/lib64/libjemalloc.so.1
```

each `sysbench.sh` test option saves results into temporary log file in `/home/sysbench/` directory which gets overwritten after each script run.

```
ls -lh /home/sysbench/
total 360K
drwxr-xr-x 2 root root 4.0K May 28 20:10 fileio
drwxr-xr-x 2 root root 4.0K May 24 16:47 mysql
-rw-r--r-- 1 root root  199 May 28 06:18 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  182 May 28 06:18 sysbench-cpu-threads-1-markdown.log
-rw-r--r-- 1 root root  201 May 28 06:18 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  184 May 28 06:18 sysbench-cpu-threads-8-markdown.log
-rw-r--r-- 1 root root  504 May 28 20:08 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  390 May 28 20:08 sysbench-fileio-rndrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:08 sysbench-fileio-rndrd-threads-1-raw.log
-rw-r--r-- 1 root root  506 May 28 20:09 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  392 May 28 20:09 sysbench-fileio-rndrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:09 sysbench-fileio-rndrd-threads-8-raw.log
-rw-r--r-- 1 root root  510 May 28 20:08 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  396 May 28 20:08 sysbench-fileio-rndwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:08 sysbench-fileio-rndwr-threads-1-raw.log
-rw-r--r-- 1 root root  510 May 28 20:10 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  396 May 28 20:10 sysbench-fileio-rndwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:10 sysbench-fileio-rndwr-threads-8-raw.log
-rw-r--r-- 1 root root  459 May 28 20:07 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  396 May 28 20:07 sysbench-fileio-seqrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.2K May 28 20:07 sysbench-fileio-seqrd-threads-1-raw.log
-rw-r--r-- 1 root root  459 May 28 20:09 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  396 May 28 20:09 sysbench-fileio-seqrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.2K May 28 20:09 sysbench-fileio-seqrd-threads-8-raw.log
-rw-r--r-- 1 root root  474 May 28 20:07 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  400 May 28 20:07 sysbench-fileio-seqwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:07 sysbench-fileio-seqwr-threads-1-raw.log
-rw-r--r-- 1 root root  474 May 28 20:09 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  400 May 28 20:09 sysbench-fileio-seqwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 20:09 sysbench-fileio-seqwr-threads-8-raw.log
-rw-r--r-- 1 root root  376 May 28 06:18 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  322 May 28 06:18 sysbench-mem-threads-1-markdown.log
-rw-r--r-- 1 root root  378 May 28 06:18 sysbench-mem-threads-8.log
-rw-r--r-- 1 root root  323 May 28 06:18 sysbench-mem-threads-8-markdown.log
-rw-r--r-- 1 root root  584 May 29 08:11 sysbench-mysql-cleanup-threads-8-insert.log
-rw-r--r-- 1 root root  582 May 29 08:01 sysbench-mysql-cleanup-threads-8.log
-rw-r--r-- 1 root root  581 May 29 09:30 sysbench-mysql-cleanup-threads-8-oltp-point-select-new.log
-rw-r--r-- 1 root root  578 May 29 09:02 sysbench-mysql-cleanup-threads-8-oltp-read-only-new.log
-rw-r--r-- 1 root root  579 May 29 09:14 sysbench-mysql-cleanup-threads-8-oltp-read-write-new.log
-rw-r--r-- 1 root root  579 May 29 09:19 sysbench-mysql-cleanup-threads-8-oltp-write-only-new.log
-rw-r--r-- 1 root root  582 May 29 08:00 sysbench-mysql-cleanup-threads-8-readonly.log
-rw-r--r-- 1 root root  590 May 29 08:37 sysbench-mysql-cleanup-threads-8-updateindex.log
-rw-r--r-- 1 root root  594 May 29 08:38 sysbench-mysql-cleanup-threads-8-updatenonindex.log
-rw-r--r-- 1 root root 1.3K May 29 08:10 sysbench-mysql-prepare-threads-8-insert.log
-rw-r--r-- 1 root root 1.3K May 29 08:01 sysbench-mysql-prepare-threads-8.log
-rw-r--r-- 1 root root 1.3K May 29 09:29 sysbench-mysql-prepare-threads-8-oltp-point-select-new.log
-rw-r--r-- 1 root root 1.3K May 29 09:02 sysbench-mysql-prepare-threads-8-oltp-read-only-new.log
-rw-r--r-- 1 root root 1.3K May 29 09:14 sysbench-mysql-prepare-threads-8-oltp-read-write-new.log
-rw-r--r-- 1 root root 1.3K May 29 09:18 sysbench-mysql-prepare-threads-8-oltp-write-only-new.log
-rw-r--r-- 1 root root 1.3K May 29 08:00 sysbench-mysql-prepare-threads-8-readonly.log
-rw-r--r-- 1 root root 1.3K May 29 08:36 sysbench-mysql-prepare-threads-8-updateindex.log
-rw-r--r-- 1 root root 1.3K May 29 08:37 sysbench-mysql-prepare-threads-8-updatenonindex.log
-rw-r--r-- 1 root root  526 May 29 08:38 sysbench-mysql-run-summary-threads-8-corrected-insert.log
-rw-r--r-- 1 root root  522 May 29 08:01 sysbench-mysql-run-summary-threads-8-corrected.log
-rw-r--r-- 1 root root  551 May 29 08:00 sysbench-mysql-run-summary-threads-8-corrected-readonly.log
-rw-r--r-- 1 root root  550 May 29 08:11 sysbench-mysql-run-summary-threads-8-insert.log
-rw-r--r-- 1 root root  554 May 29 08:01 sysbench-mysql-run-summary-threads-8.log
-rw-r--r-- 1 root root  349 May 29 08:38 sysbench-mysql-run-summary-threads-8-markdown-insert.log
-rw-r--r-- 1 root root  345 May 29 08:01 sysbench-mysql-run-summary-threads-8-markdown.log
-rw-r--r-- 1 root root  335 May 29 08:00 sysbench-mysql-run-summary-threads-8-markdown-readonly.log
-rw-r--r-- 1 root root  545 May 29 09:30 sysbench-mysql-run-summary-threads-8-oltp-point-select-new.log
-rw-r--r-- 1 root root  545 May 29 09:02 sysbench-mysql-run-summary-threads-8-oltp-read-only-new.log
-rw-r--r-- 1 root root  511 May 29 09:30 sysbench-mysql-run-summary-threads-8-oltp-read-write-new-corrected.log
-rw-r--r-- 1 root root  552 May 29 09:14 sysbench-mysql-run-summary-threads-8-oltp-read-write-new.log
-rw-r--r-- 1 root root  348 May 29 09:30 sysbench-mysql-run-summary-threads-8-oltp-read-write-new-markdown.log
-rw-r--r-- 1 root root  549 May 29 09:19 sysbench-mysql-run-summary-threads-8-oltp-write-only-new.log
-rw-r--r-- 1 root root  583 May 29 08:00 sysbench-mysql-run-summary-threads-8-readonly.log
-rw-r--r-- 1 root root  556 May 29 08:37 sysbench-mysql-run-summary-threads-8-updateindex.log
-rw-r--r-- 1 root root  560 May 29 08:38 sysbench-mysql-run-summary-threads-8-updatenonindex.log
-rw-r--r-- 1 root root 5.0K May 29 08:11 sysbench-mysql-run-threads-8-insert.log
-rw-r--r-- 1 root root 5.2K May 29 08:01 sysbench-mysql-run-threads-8.log
-rw-r--r-- 1 root root 5.0K May 29 09:30 sysbench-mysql-run-threads-8-oltp-point-select-new.log
-rw-r--r-- 1 root root 5.1K May 29 09:02 sysbench-mysql-run-threads-8-oltp-read-only-new.log
-rw-r--r-- 1 root root 5.2K May 29 09:14 sysbench-mysql-run-threads-8-oltp-read-write-new.log
-rw-r--r-- 1 root root 5.2K May 29 09:19 sysbench-mysql-run-threads-8-oltp-write-only-new.log
-rw-r--r-- 1 root root 5.0K May 29 08:00 sysbench-mysql-run-threads-8-readonly.log
-rw-r--r-- 1 root root 4.9K May 29 08:37 sysbench-mysql-run-threads-8-updateindex.log
-rw-r--r-- 1 root root 5.1K May 29 08:38 sysbench-mysql-run-threads-8-updatenonindex.log
-rw-r--r-- 1 root root 1.4K May 29 08:38 sysbench-mysql-table-list-insert.log
-rw-r--r-- 1 root root 1.4K May 29 09:29 sysbench-mysql-table-list.log
-rw-r--r-- 1 root root 1.4K May 29 08:00 sysbench-mysql-table-list-readonly.log
```

## sysbench install

```
mkdir -p /root/tools/sysbench
cd /root/tools/sysbench
wget -O /root/tools/sysbench/sysbench.sh https://github.com/centminmod/centminmod-sysbench/raw/master/sysbench.sh
chmod +x sysbench.sh
./sysbench.sh install
```

## sysbench update

```
mkdir -p /root/tools/sysbench
cd /root/tools/sysbench
wget -O /root/tools/sysbench/sysbench.sh https://github.com/centminmod/centminmod-sysbench/raw/master/sysbench.sh
chmod +x sysbench.sh
./sysbench.sh update
```

## sysbench usage

```
./sysbench.sh 

Usage:
./sysbench.sh install
./sysbench.sh update
./sysbench.sh cpu
./sysbench.sh mem
./sysbench.sh file
./sysbench.sh mysql
./sysbench.sh mysqlro
./sysbench.sh mysqlinsert
./sysbench.sh mysqlupdateindex
./sysbench.sh mysqlupdatenonindex
./sysbench.sh mysqloltpnew
./sysbench.sh mysqlreadonly-new
./sysbench.sh mysqlwriteonly-new
./sysbench.sh mysqlpointselect-new
```

## sysbench cpu

sysbench cpu tests test both single thread and max cpu core/thread count for comparison

```
./sysbench.sh cpu                     
-------------------------------------------
System Information
-------------------------------------------

3.10.0-862.2.3.el7.x86_64

CentOS Linux release 7.5.1804 (Core) 

Centmin Mod 
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                8
On-line CPU(s) list:   0-7
Thread(s) per core:    2
Core(s) per socket:    4
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 60
Model name:            Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz
Stepping:              3
CPU MHz:               4199.951
CPU max MHz:           4400.0000
CPU min MHz:           800.0000
BogoMIPS:              7981.67
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              8192K
NUMA node0 CPU(s):     0-7
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm epb tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs dtherm ida arat pln pts

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm epb tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs dtherm ida arat pln pts

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4400.0000 800.0000
1   0    0      1    1:1:1:0       yes    4400.0000 800.0000
2   0    0      2    2:2:2:0       yes    4400.0000 800.0000
3   0    0      3    3:3:3:0       yes    4400.0000 800.0000
4   0    0      0    0:0:0:0       yes    4400.0000 800.0000
5   0    0      1    1:1:1:0       yes    4400.0000 800.0000
6   0    0      2    2:2:2:0       yes    4400.0000 800.0000
7   0    0      3    3:3:3:0       yes    4400.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31974       10947       16094         173        4932       20417
Low:          31974       15879       16094
High:             0           0           0
Swap:          2045           1        2044

Filesystem      Size  Used Avail Use% Mounted on
/dev/md1         69G   29G   37G  44% /
devtmpfs         16G     0   16G   0% /dev
tmpfs            16G     0   16G   0% /dev/shm
tmpfs            16G  121M   16G   1% /run
tmpfs            16G     0   16G   0% /sys/fs/cgroup
tmpfs            16G  972K   16G   1% /tmp
/dev/md2        151G   11G  133G   8% /home
tmpfs           3.2G     0  3.2G   0% /run/user/0


sysbench cpu --cpu-max-prime=20000 --threads=1 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
prime: 20000
events/s: 525.15
time: 10.0016s
min: 1.90
avg: 1.90
max: 2.35
95th: 1.89

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.15 | 10.0016s | 1.90 | 1.90 | 2.35 | 1.89 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.14,1,525.15,10.0016s,1.90,1.90,2.35,1.89 

sysbench cpu --cpu-max-prime=20000 --threads=8 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
prime: 20000
events/s: 3229.16
time: 10.0020s
min: 1.90
avg: 2.48
max: 11.47
95th: 2.48

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 8 | 3229.16 | 10.0020s | 1.90 | 2.48 | 11.47 | 2.48 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.14,8,3229.16,10.0020s,1.90,2.48,11.47,2.48 
```

Markdown results table

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.15 | 10.0016s | 1.90 | 1.90 | 2.35 | 1.89 |
| 1.0.14 | 8 | 3229.16 | 10.0020s | 1.90 | 2.48 | 11.47 | 2.48 |

## sysbench memory

sysbench memory tests test both single thread and max cpu core/thread count for comparison

```
./sysbench.sh mem
-------------------------------------------
System Information
-------------------------------------------

3.10.0-862.2.3.el7.x86_64

CentOS Linux release 7.5.1804 (Core) 

Centmin Mod 
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                8
On-line CPU(s) list:   0-7
Thread(s) per core:    2
Core(s) per socket:    4
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 60
Model name:            Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz
Stepping:              3
CPU MHz:               4200.195
CPU max MHz:           4400.0000
CPU min MHz:           800.0000
BogoMIPS:              7981.67
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              8192K
NUMA node0 CPU(s):     0-7
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm epb tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs dtherm ida arat pln pts

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm epb tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs dtherm ida arat pln pts

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4400.0000 800.0000
1   0    0      1    1:1:1:0       yes    4400.0000 800.0000
2   0    0      2    2:2:2:0       yes    4400.0000 800.0000
3   0    0      3    3:3:3:0       yes    4400.0000 800.0000
4   0    0      0    0:0:0:0       yes    4400.0000 800.0000
5   0    0      1    1:1:1:0       yes    4400.0000 800.0000
6   0    0      2    2:2:2:0       yes    4400.0000 800.0000
7   0    0      3    3:3:3:0       yes    4400.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31974       10946       16095         173        4932       20417
Low:          31974       15879       16095
High:             0           0           0
Swap:          2045           1        2044

Filesystem      Size  Used Avail Use% Mounted on
/dev/md1         69G   29G   37G  44% /
devtmpfs         16G     0   16G   0% /dev
tmpfs            16G     0   16G   0% /dev/shm
tmpfs            16G  121M   16G   1% /run
tmpfs            16G     0   16G   0% /sys/fs/cgroup
tmpfs            16G  972K   16G   1% /tmp
/dev/md2        151G   11G  133G   8% /home
tmpfs           3.2G     0  3.2G   0% /run/user/0


sysbench memory --threads=1 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (8179314.39 per second)
transferred (7987.61 MiB/sec)
time: 0.1270s
min: 0.00
avg: 0.00
max: 0.00
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7987.61 | 0.1270s | 0.00 | 0.00 | 0.00 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.14,1,1KiB,1024MiB,read,1048576,7987.61,0.1270s,0.00,0.00,0.00,0.00 

sysbench memory --threads=8 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (32721691.65 per second)
transferred (31954.78 MiB/sec)
time: 0.0308s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 31954.78 | 0.0308s | 0.00 | 0.00 | 0.01 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.14,8,1KiB,1024MiB,read,1048576,31954.78,0.0308s,0.00,0.00,0.01,0.00 
```

Markdown results table

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7987.61 | 0.1270s | 0.00 | 0.00 | 0.00 | 0.00 |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 31954.78 | 0.0308s | 0.00 | 0.00 | 0.01 | 0.00 |

## sysbench fileio

sysbench fileio disk performance tests are conducted in directory `/home/sysbench/fileio` with the presumption that `/home` partition is usually the largest disk free space partition on the server to ensure you don't run out of disk space. This fileio test tests both single thread and max cpu core/thread count for comparison using a 2048MB file size.

```
./sysbench.sh file                    

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqrd prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqrd-threads-1-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 36088.03
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 140.97
written-MiB/s: 0.00
time: 10.0000s
min: 0.02
avg: 0.03
max: 1.63
95th: 0.03

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 36088.03 | 0.00 | 0.00 | 140.97 | 0.00 | 10.0000s | 0.02 | 0.03 | 1.63 | 0.03 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,read,36088.03,0.00,0.00,140.97,0.00,10.0000s,0.02,0.03,1.63,0.03 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqwr prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqwr-threads-1-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 15338.05
fsyncs/s: 19621.21
read-MiB/s: 0.00
written-MiB/s: 59.91
time: 10.0000s
min: 0.02
avg: 0.03
max: 1.50
95th: 0.04

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15338.05 | 19621.21 | 0.00 | 59.91 | 10.0000s | 0.02 | 0.03 | 1.50 | 0.04 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,write,0.00,15338.05,19621.21,0.00,59.91,10.0000s,0.02,0.03,1.50,0.04 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndrd prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndrd-threads-1-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 8316.47
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 32.49
written-MiB/s: 0.00
time: 10.0001s
min: 0.06
avg: 0.12
max: 2.53
95th: 0.14

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 8316.47 | 0.00 | 0.00 | 32.49 | 0.00 | 10.0001s | 0.06 | 0.12 | 2.53 | 0.14 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,read,8316.47,0.00,0.00,32.49,0.00,10.0001s,0.06,0.12,2.53,0.14 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndwr prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndwr-threads-1-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 15368.08
fsyncs/s: 19658.94
read-MiB/s: 0.00
written-MiB/s: 60.03
time: 10.0000s
min: 0.02
avg: 0.03
max: 2.21
95th: 0.04

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15368.08 | 19658.94 | 0.00 | 60.03 | 10.0000s | 0.02 | 0.03 | 2.21 | 0.04 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,write,0.00,15368.08,19658.94,0.00,60.03,10.0000s,0.02,0.03,2.21,0.04 



sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqrd prepare

sysbench fileio --threads=8 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqrd-threads-8-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 97419.57
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 380.55
written-MiB/s: 0.00
time: 10.0001s
min: 0.02
avg: 0.08
max: 2.80
95th: 0.08

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 97419.57 | 0.00 | 0.00 | 380.55 | 0.00 | 10.0001s | 0.02 | 0.08 | 2.80 | 0.08 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,read,97419.57,0.00,0.00,380.55,0.00,10.0001s,0.02,0.08,2.80,0.08 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqwr prepare

sysbench fileio --threads=8 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqwr-threads-8-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 14926.47
fsyncs/s: 19094.62
read-MiB/s: 0.00
written-MiB/s: 58.31
time: 10.0003s
min: 0.02
avg: 0.23
max: 5.76
95th: 0.59

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 14926.47 | 19094.62 | 0.00 | 58.31 | 10.0003s | 0.02 | 0.23 | 5.76 | 0.59 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,write,0.00,14926.47,19094.62,0.00,58.31,10.0003s,0.02,0.23,5.76,0.59 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndrd prepare

sysbench fileio --threads=8 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndrd-threads-8-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 62997.92
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 246.09
written-MiB/s: 0.00
time: 10.0002s
min: 0.05
avg: 0.13
max: 1.01
95th: 0.17

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 62997.92 | 0.00 | 0.00 | 246.09 | 0.00 | 10.0002s | 0.05 | 0.13 | 1.01 | 0.17 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,read,62997.92,0.00,0.00,246.09,0.00,10.0002s,0.05,0.13,1.01,0.17 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndwr prepare

sysbench fileio --threads=8 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndwr-threads-8-raw.log

sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 22746.82
fsyncs/s: 29115.43
read-MiB/s: 0.00
written-MiB/s: 88.85
time: 10.0002s
min: 0.02
avg: 0.15
max: 9.79
95th: 0.23

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 22746.82 | 29115.43 | 0.00 | 88.85 | 10.0002s | 0.02 | 0.15 | 9.79 | 0.23 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,write,0.00,22746.82,29115.43,0.00,88.85,10.0002s,0.02,0.15,9.79,0.23 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 36088.03 | 0.00 | 0.00 | 140.97 | 0.00 | 10.0000s | 0.02 | 0.03 | 1.63 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15338.05 | 19621.21 | 0.00 | 59.91 | 10.0000s | 0.02 | 0.03 | 1.50 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 97419.57 | 0.00 | 0.00 | 380.55 | 0.00 | 10.0001s | 0.02 | 0.08 | 2.80 | 0.08 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 14926.47 | 19094.62 | 0.00 | 58.31 | 10.0003s | 0.02 | 0.23 | 5.76 | 0.59 |

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 8316.47 | 0.00 | 0.00 | 32.49 | 0.00 | 10.0001s | 0.06 | 0.12 | 2.53 | 0.14 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15368.08 | 19658.94 | 0.00 | 60.03 | 10.0000s | 0.02 | 0.03 | 2.21 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 62997.92 | 0.00 | 0.00 | 246.09 | 0.00 | 10.0002s | 0.05 | 0.13 | 1.01 | 0.17 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 22746.82 | 29115.43 | 0.00 | 88.85 | 10.0002s | 0.02 | 0.15 | 9.79 | 0.23 |
```

Parsing sysbench fileio for markdown table

Sequential

```
ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'seq' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 36088.03 | 0.00 | 0.00 | 140.97 | 0.00 | 10.0000s | 0.02 | 0.03 | 1.63 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15338.05 | 19621.21 | 0.00 | 59.91 | 10.0000s | 0.02 | 0.03 | 1.50 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 97419.57 | 0.00 | 0.00 | 380.55 | 0.00 | 10.0001s | 0.02 | 0.08 | 2.80 | 0.08 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 14926.47 | 19094.62 | 0.00 | 58.31 | 10.0003s | 0.02 | 0.23 | 5.76 | 0.59 |
```

Random

```
ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'rnd' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 8316.47 | 0.00 | 0.00 | 32.49 | 0.00 | 10.0001s | 0.06 | 0.12 | 2.53 | 0.14 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15368.08 | 19658.94 | 0.00 | 60.03 | 10.0000s | 0.02 | 0.03 | 2.21 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 62997.92 | 0.00 | 0.00 | 246.09 | 0.00 | 10.0002s | 0.05 | 0.13 | 1.01 | 0.17 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 22746.82 | 29115.43 | 0.00 | 88.85 | 10.0002s | 0.02 | 0.15 | 9.79 | 0.23 |
```

Markdown results table - sequential

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 36088.03 | 0.00 | 0.00 | 140.97 | 0.00 | 10.0000s | 0.02 | 0.03 | 1.63 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15338.05 | 19621.21 | 0.00 | 59.91 | 10.0000s | 0.02 | 0.03 | 1.50 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 97419.57 | 0.00 | 0.00 | 380.55 | 0.00 | 10.0001s | 0.02 | 0.08 | 2.80 | 0.08 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 14926.47 | 19094.62 | 0.00 | 58.31 | 10.0003s | 0.02 | 0.23 | 5.76 | 0.59 |

Markdown results table - random

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 8316.47 | 0.00 | 0.00 | 32.49 | 0.00 | 10.0001s | 0.06 | 0.12 | 2.53 | 0.14 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 15368.08 | 19658.94 | 0.00 | 60.03 | 10.0000s | 0.02 | 0.03 | 2.21 | 0.04 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 62997.92 | 0.00 | 0.00 | 246.09 | 0.00 | 10.0002s | 0.05 | 0.13 | 1.01 | 0.17 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 22746.82 | 29115.43 | 0.00 | 88.85 | 10.0002s | 0.02 | 0.15 | 9.79 | 0.23 |

## sysbench mysql read/write OLTP

```
./sysbench.sh mysql

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 150000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 150000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 150000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest6'
Creating secondary indexes on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest7'
Creating secondary indexes on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest8'
Creating secondary indexes on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql benchmark:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 1864.36 qps: 37389.04 (r/w/o: 26192.90/7460.43/3735.71) lat (ms,95%): 5.99 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2235.40 qps: 44698.02 (r/w/o: 31284.61/8941.60/4471.80) lat (ms,95%): 4.74 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 2364.04 qps: 47278.77 (r/w/o: 33097.54/9453.15/4728.08) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 2390.97 qps: 47833.35 (r/w/o: 33485.54/9565.87/4781.93) lat (ms,95%): 4.57 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2435.99 qps: 48686.79 (r/w/o: 34066.85/9747.96/4871.98) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2408.04 qps: 48177.84 (r/w/o: 33734.59/9627.17/4816.08) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2466.99 qps: 49342.78 (r/w/o: 34538.85/9869.96/4933.98) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2442.05 qps: 48859.03 (r/w/o: 34206.72/9768.21/4884.10) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2432.99 qps: 48640.87 (r/w/o: 34045.91/9728.97/4865.99) lat (ms,95%): 4.57 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2485.89 qps: 49740.76 (r/w/o: 34823.43/9945.55/4971.78) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2590.08 qps: 51840.63 (r/w/o: 36270.14/10390.33/5180.16) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2451.90 qps: 48967.06 (r/w/o: 34287.64/9775.61/4903.81) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2467.07 qps: 49351.48 (r/w/o: 34549.03/9868.30/4934.15) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2484.91 qps: 49708.23 (r/w/o: 34792.76/9945.65/4969.82) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2527.09 qps: 50528.72 (r/w/o: 35371.21/10103.34/5054.17) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2512.30 qps: 50278.96 (r/w/o: 35201.17/10053.19/5024.60) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2538.68 qps: 50737.57 (r/w/o: 35506.50/10153.72/5077.36) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2544.08 qps: 50880.63 (r/w/o: 35616.14/10176.33/5088.16) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2543.96 qps: 50887.13 (r/w/o: 35620.39/10179.83/5086.91) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2527.39 qps: 50555.78 (r/w/o: 35397.44/10102.56/5055.78) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 2512.15 qps: 50233.91 (r/w/o: 35160.04/10049.58/5024.29) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 2533.48 qps: 50660.50 (r/w/o: 35461.65/10131.90/5066.95) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 2531.72 qps: 50649.41 (r/w/o: 35451.09/10133.88/5064.44) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 2544.31 qps: 50890.14 (r/w/o: 35627.30/10175.23/5087.61) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 2479.03 qps: 49552.57 (r/w/o: 34680.40/9915.11/4957.06) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 2505.96 qps: 50130.15 (r/w/o: 35097.40/10019.83/5012.91) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 2539.98 qps: 50793.62 (r/w/o: 35551.73/10161.92/5079.96) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 2493.98 qps: 49865.68 (r/w/o: 34901.78/9976.94/4986.97) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 2470.06 qps: 49407.26 (r/w/o: 34587.88/9878.25/4941.13) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 2542.89 qps: 50873.82 (r/w/o: 35617.48/10170.56/5085.78) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1034292
        write:                           295512
        other:                           147756
        total:                           1477560
    transactions:                        73878  (2462.24 per sec.)
    queries:                             1477560 (49244.71 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0034s
    total number of events:              73878

Latency (ms):
         min:                                    1.21
         avg:                                    3.25
         max:                                   89.42
         95th percentile:                        4.25
         sum:                               239887.88

Threads fairness:
    events (avg/stddev):           9234.7500/40.26
    execution time (avg/stddev):   29.9860/0.00


sysbench mysql summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1034292
write: 295512
other: 147756
total: 1477560
transactions/s: 2462.24
queries/s: 49244.71
time: 30.0034s
min: 1.21
avg: 3.25
max: 89.42
95th: 4.25

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1034292 | 295512 | 147756 | 1477560 | 2462.24 | 49244.71 | 30.0034s | 1.21 | 3.25 | 89.42 | 4.25 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp.lua,1.0.14,8,1034292,295512,147756,1477560,2462.24,49244.71,30.0034s,1.21,3.25,89.42,4.25 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1034292 | 295512 | 147756 | 1477560 | 2462.24 | 49244.71 | 30.0034s | 1.21 | 3.25 | 89.42 | 4.25 |


## sysbench mysql read only OLTP

```
./sysbench.sh mysqlro                 

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 150000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 150000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 150000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest6'
Creating secondary indexes on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest7'
Creating secondary indexes on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest8'
Creating secondary indexes on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql read only benchmark:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2940.83 qps: 41243.55 (r/w/o: 41243.55/0.00/0.00) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2879.43 qps: 40311.04 (r/w/o: 40311.04/0.00/0.00) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 3392.98 qps: 47482.73 (r/w/o: 47482.73/0.00/0.00) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 3507.92 qps: 49140.89 (r/w/o: 49140.89/0.00/0.00) lat (ms,95%): 3.19 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 3311.10 qps: 46319.37 (r/w/o: 46319.37/0.00/0.00) lat (ms,95%): 3.36 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 3152.98 qps: 44153.70 (r/w/o: 44153.70/0.00/0.00) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 3009.00 qps: 42129.02 (r/w/o: 42129.02/0.00/0.00) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2878.04 qps: 40291.54 (r/w/o: 40291.54/0.00/0.00) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2843.98 qps: 39821.65 (r/w/o: 39821.65/0.00/0.00) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2782.99 qps: 38957.82 (r/w/o: 38957.82/0.00/0.00) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2750.02 qps: 38486.23 (r/w/o: 38486.23/0.00/0.00) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2775.02 qps: 38849.31 (r/w/o: 38849.31/0.00/0.00) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2752.96 qps: 38567.48 (r/w/o: 38567.48/0.00/0.00) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2685.06 qps: 37589.83 (r/w/o: 37589.83/0.00/0.00) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2657.98 qps: 37206.72 (r/w/o: 37206.72/0.00/0.00) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2664.98 qps: 37311.68 (r/w/o: 37311.68/0.00/0.00) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2623.00 qps: 36714.95 (r/w/o: 36714.95/0.00/0.00) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2659.99 qps: 37266.87 (r/w/o: 37266.87/0.00/0.00) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2610.03 qps: 36509.45 (r/w/o: 36509.45/0.00/0.00) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2607.99 qps: 36531.92 (r/w/o: 36531.92/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 2593.98 qps: 36282.69 (r/w/o: 36282.69/0.00/0.00) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 2585.00 qps: 36206.94 (r/w/o: 36206.94/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 2550.01 qps: 35684.12 (r/w/o: 35684.12/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 2571.99 qps: 36021.89 (r/w/o: 36021.89/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 2567.00 qps: 35952.95 (r/w/o: 35952.95/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 2550.98 qps: 35712.65 (r/w/o: 35712.65/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 2524.06 qps: 35325.91 (r/w/o: 35325.91/0.00/0.00) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 2564.97 qps: 35901.57 (r/w/o: 35901.57/0.00/0.00) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 2523.00 qps: 35335.05 (r/w/o: 35335.05/0.00/0.00) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 2508.93 qps: 35123.96 (r/w/o: 35123.96/0.00/0.00) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1162532
        write:                           0
        other:                           0
        total:                           1162532
    transactions:                        83038  (2767.55 per sec.)
    queries:                             1162532 (38745.68 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0031s
    total number of events:              83038

Latency (ms):
         min:                                    0.33
         avg:                                    2.89
         max:                                   25.15
         95th percentile:                        4.10
         sum:                               239892.92

Threads fairness:
    events (avg/stddev):           10379.7500/19.02
    execution time (avg/stddev):   29.9866/0.00


sysbench mysql read only summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1162532
write: 0
other: 0
total: 1162532
transactions/s: 2767.55
queries/s: 38745.68
time: 30.0031s
min: 0.33
avg: 2.89
max: 25.15
95th: 4.10

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1162532 | 0 | 0 | 1162532 | 2767.55 | 38745.68 | 30.0031s | 0.33 | 2.89 | 25.15 | 4.10 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp.lua,1.0.14,8,1162532,0,0,1162532,2767.55,38745.68,30.0031s,0.33,2.89,25.15,4.10 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1162532 | 0 | 0 | 1162532 | 2767.55 | 38745.68 | 30.0031s | 0.33 | 2.89 | 25.15 | 4.10 |

## sysbench mysql insert

```
./sysbench.sh mysqlinsert             

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench insert.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 150000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 150000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 150000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest6'
Creating secondary indexes on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest7'
Creating secondary indexes on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest8'
Creating secondary indexes on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql insert benchmark:
sysbench insert.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 57205.28 qps: 57205.28 (r/w/o: 0.00/57205.28/0.00) lat (ms,95%): 0.16 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 70756.10 qps: 70757.10 (r/w/o: 0.00/70757.10/0.00) lat (ms,95%): 0.10 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 74076.73 qps: 74075.73 (r/w/o: 0.00/74075.73/0.00) lat (ms,95%): 0.12 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 74243.13 qps: 74243.13 (r/w/o: 0.00/74243.13/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 70833.83 qps: 70833.83 (r/w/o: 0.00/70833.83/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 68455.38 qps: 68455.38 (r/w/o: 0.00/68455.38/0.00) lat (ms,95%): 0.12 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 73203.96 qps: 73203.96 (r/w/o: 0.00/73203.96/0.00) lat (ms,95%): 0.15 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 67995.70 qps: 67995.70 (r/w/o: 0.00/67995.70/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 72988.12 qps: 72988.12 (r/w/o: 0.00/72988.12/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 69973.13 qps: 69973.13 (r/w/o: 0.00/69973.13/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 68153.44 qps: 68154.44 (r/w/o: 0.00/68154.44/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 74088.09 qps: 74088.09 (r/w/o: 0.00/74088.09/0.00) lat (ms,95%): 0.12 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 72437.23 qps: 72436.23 (r/w/o: 0.00/72436.23/0.00) lat (ms,95%): 0.15 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 66557.12 qps: 66557.12 (r/w/o: 0.00/66557.12/0.00) lat (ms,95%): 0.14 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 68488.12 qps: 68490.12 (r/w/o: 0.00/68490.12/0.00) lat (ms,95%): 0.17 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 67257.03 qps: 67256.03 (r/w/o: 0.00/67256.03/0.00) lat (ms,95%): 0.17 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 68622.82 qps: 68621.82 (r/w/o: 0.00/68621.82/0.00) lat (ms,95%): 0.13 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 68490.75 qps: 68491.75 (r/w/o: 0.00/68491.75/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 71824.21 qps: 71823.21 (r/w/o: 0.00/71823.21/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 70616.11 qps: 70616.11 (r/w/o: 0.00/70616.11/0.00) lat (ms,95%): 0.18 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 67790.09 qps: 67790.09 (r/w/o: 0.00/67790.09/0.00) lat (ms,95%): 0.15 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 72071.78 qps: 72071.78 (r/w/o: 0.00/72071.78/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 70617.42 qps: 70617.42 (r/w/o: 0.00/70617.42/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 75780.12 qps: 75780.12 (r/w/o: 0.00/75780.12/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 72526.52 qps: 72527.52 (r/w/o: 0.00/72527.52/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 78733.30 qps: 78732.30 (r/w/o: 0.00/78732.30/0.00) lat (ms,95%): 0.10 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 70832.18 qps: 70832.18 (r/w/o: 0.00/70832.18/0.00) lat (ms,95%): 0.10 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 76139.04 qps: 76139.04 (r/w/o: 0.00/76139.04/0.00) lat (ms,95%): 0.11 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 66043.01 qps: 66043.01 (r/w/o: 0.00/66043.01/0.00) lat (ms,95%): 0.15 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 74393.86 qps: 74393.86 (r/w/o: 0.00/74393.86/0.00) lat (ms,95%): 0.12 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           2121268
        other:                           0
        total:                           2121268
    transactions:                        2121268 (70702.49 per sec.)
    queries:                             2121268 (70702.49 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0017s
    total number of events:              2121268

Latency (ms):
         min:                                    0.04
         avg:                                    0.11
         max:                                  128.65
         95th percentile:                        0.12
         sum:                               237606.19

Threads fairness:
    events (avg/stddev):           265158.5000/781.35
    execution time (avg/stddev):   29.7008/0.00


sysbench mysql insert summary:
sysbench insert.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 0
write: 2121268
other: 0
total: 2121268
transactions/s: 70702.49
queries/s: 70702.49
time: 30.0017s
min: 0.04
avg: 0.11
max: 128.65
95th: 0.12

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| insert.lua | 1.0.14 | 8 | 0 | 2121268 | 0 | 2121268 | 70702.49 | 70702.49 | 30.0017s | 0.04 | 0.11 | 128.65 | 0.12 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
insert.lua,1.0.14,8,0,2121268,0,2121268,70702.49,70702.49,30.0017s,0.04,0.11,128.65,0.12 

sysbench mysql cleanup database: sbt
sysbench insert.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| insert.lua | 1.0.14 | 8 | 0 | 2121268 | 0 | 2121268 | 70702.49 | 70702.49 | 30.0017s | 0.04 | 0.11 | 128.65 | 0.12 |

## sysbench mysql update index

```
./sysbench.sh mysqlupdateindex

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench update_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 150000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 150000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 150000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest6'
Creating secondary indexes on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest7'
Creating secondary indexes on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest8'
Creating secondary indexes on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql update index benchmark:
sysbench update_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 18404.74 qps: 18404.74 (r/w/o: 0.00/18404.74/0.00) lat (ms,95%): 0.74 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 27908.45 qps: 27908.45 (r/w/o: 0.00/27908.45/0.00) lat (ms,95%): 0.61 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 29978.24 qps: 29978.24 (r/w/o: 0.00/29978.24/0.00) lat (ms,95%): 0.56 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 27868.20 qps: 27868.20 (r/w/o: 0.00/27868.20/0.00) lat (ms,95%): 0.61 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 29661.13 qps: 29661.13 (r/w/o: 0.00/29661.13/0.00) lat (ms,95%): 0.58 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 34050.46 qps: 34050.46 (r/w/o: 0.00/34050.46/0.00) lat (ms,95%): 0.51 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 41959.21 qps: 41959.21 (r/w/o: 0.00/41959.21/0.00) lat (ms,95%): 0.46 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 34654.08 qps: 34654.08 (r/w/o: 0.00/34654.08/0.00) lat (ms,95%): 0.48 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 45251.59 qps: 45251.59 (r/w/o: 0.00/45251.59/0.00) lat (ms,95%): 0.43 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 31281.31 qps: 31281.31 (r/w/o: 0.00/31281.31/0.00) lat (ms,95%): 0.48 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 37782.01 qps: 37782.01 (r/w/o: 0.00/37782.01/0.00) lat (ms,95%): 0.46 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 35123.91 qps: 35123.91 (r/w/o: 0.00/35123.91/0.00) lat (ms,95%): 0.52 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 36527.99 qps: 36527.99 (r/w/o: 0.00/36527.99/0.00) lat (ms,95%): 0.47 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 36733.17 qps: 36733.17 (r/w/o: 0.00/36733.17/0.00) lat (ms,95%): 0.49 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 37033.59 qps: 37034.59 (r/w/o: 0.00/37034.59/0.00) lat (ms,95%): 0.46 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 39655.45 qps: 39654.45 (r/w/o: 0.00/39654.45/0.00) lat (ms,95%): 0.41 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 38778.90 qps: 38778.90 (r/w/o: 0.00/38778.90/0.00) lat (ms,95%): 0.43 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 39284.61 qps: 39284.61 (r/w/o: 0.00/39284.61/0.00) lat (ms,95%): 0.42 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 43994.43 qps: 43994.43 (r/w/o: 0.00/43994.43/0.00) lat (ms,95%): 0.42 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 35642.09 qps: 35642.09 (r/w/o: 0.00/35642.09/0.00) lat (ms,95%): 0.46 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 38706.92 qps: 38706.92 (r/w/o: 0.00/38706.92/0.00) lat (ms,95%): 0.45 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 36003.92 qps: 36003.92 (r/w/o: 0.00/36003.92/0.00) lat (ms,95%): 0.46 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 39688.18 qps: 39688.18 (r/w/o: 0.00/39688.18/0.00) lat (ms,95%): 0.43 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 39505.89 qps: 39505.89 (r/w/o: 0.00/39505.89/0.00) lat (ms,95%): 0.44 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 44236.26 qps: 44237.26 (r/w/o: 0.00/44237.26/0.00) lat (ms,95%): 0.42 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 35857.50 qps: 35856.50 (r/w/o: 0.00/35856.50/0.00) lat (ms,95%): 0.44 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 43304.10 qps: 43304.10 (r/w/o: 0.00/43304.10/0.00) lat (ms,95%): 0.40 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 39024.66 qps: 39024.66 (r/w/o: 0.00/39024.66/0.00) lat (ms,95%): 0.42 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 43719.82 qps: 43719.82 (r/w/o: 0.00/43719.82/0.00) lat (ms,95%): 0.40 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           1100238
        other:                           0
        total:                           1100238
    transactions:                        1100238 (36671.37 per sec.)
    queries:                             1100238 (36671.37 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0016s
    total number of events:              1100238

Latency (ms):
         min:                                    0.05
         avg:                                    0.22
         max:                                  211.43
         95th percentile:                        0.47
         sum:                               238763.18

Threads fairness:
    events (avg/stddev):           137529.7500/1243.41
    execution time (avg/stddev):   29.8454/0.00


sysbench mysql update index summary:
sysbench update_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 0
write: 1100238
other: 0
total: 1100238
transactions/s: 36671.37
queries/s: 36671.37
time: 30.0016s
min: 0.05
avg: 0.22
max: 211.43
95th: 0.47

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| update_index.lua | 1.0.14 | 8 | 0 | 1100238 | 0 | 1100238 | 36671.37 | 36671.37 | 30.0016s | 0.05 | 0.22 | 211.43 | 0.47 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
update_index.lua,1.0.14,8,0,1100238,0,1100238,36671.37,36671.37,30.0016s,0.05,0.22,211.43,0.47 

sysbench mysql cleanup database: sbt
sysbench update_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| update_index.lua | 1.0.14 | 8 | 0 | 1100238 | 0 | 1100238 | 36671.37 | 36671.37 | 30.0016s | 0.05 | 0.22 | 211.43 | 0.47 |

## sysbench mysql update nonindex

```
./sysbench.sh mysqlupdatenonindex

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench update_non_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 150000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 150000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...
Creating table 'sbtest5'...
Inserting 150000 records into 'sbtest5'
Creating secondary indexes on 'sbtest5'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest6'
Creating secondary indexes on 'sbtest6'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest7'
Creating secondary indexes on 'sbtest7'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest8'
Creating secondary indexes on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 148032 Rows    | InnoDB         | 32.56MB   | 2.52MB     | 35.08MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql update index benchmark:
sysbench update_non_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 61668.91 qps: 61668.91 (r/w/o: 0.00/61668.91/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 57845.44 qps: 57845.44 (r/w/o: 0.00/57845.44/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 62402.23 qps: 62402.23 (r/w/o: 0.00/62402.23/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 61606.89 qps: 61606.89 (r/w/o: 0.00/61606.89/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 61487.69 qps: 61487.69 (r/w/o: 0.00/61487.69/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 61757.11 qps: 61757.11 (r/w/o: 0.00/61757.11/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 62889.63 qps: 62889.63 (r/w/o: 0.00/62889.63/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 60883.01 qps: 60883.01 (r/w/o: 0.00/60883.01/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 65868.88 qps: 65868.88 (r/w/o: 0.00/65868.88/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 61952.51 qps: 61952.51 (r/w/o: 0.00/61952.51/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 61626.85 qps: 61626.85 (r/w/o: 0.00/61626.85/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 62118.90 qps: 62118.90 (r/w/o: 0.00/62118.90/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 61895.22 qps: 61895.22 (r/w/o: 0.00/61895.22/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 61261.34 qps: 61261.34 (r/w/o: 0.00/61261.34/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 59882.49 qps: 59882.49 (r/w/o: 0.00/59882.49/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 60048.96 qps: 60048.96 (r/w/o: 0.00/60048.96/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 61743.15 qps: 61743.15 (r/w/o: 0.00/61743.15/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 61652.01 qps: 61653.01 (r/w/o: 0.00/61653.01/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 61580.88 qps: 61579.88 (r/w/o: 0.00/61579.88/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 60778.17 qps: 60779.17 (r/w/o: 0.00/60779.17/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 61367.57 qps: 61366.57 (r/w/o: 0.00/61366.57/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 62127.99 qps: 62127.99 (r/w/o: 0.00/62127.99/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 60707.18 qps: 60707.18 (r/w/o: 0.00/60707.18/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 61073.89 qps: 61073.89 (r/w/o: 0.00/61073.89/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 60884.07 qps: 60884.07 (r/w/o: 0.00/60884.07/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 58896.99 qps: 58896.99 (r/w/o: 0.00/58896.99/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 61416.64 qps: 61416.64 (r/w/o: 0.00/61416.64/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 71645.18 qps: 71645.18 (r/w/o: 0.00/71645.18/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 50376.46 qps: 50376.46 (r/w/o: 0.00/50376.46/0.00) lat (ms,95%): 0.19 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 63475.96 qps: 63475.96 (r/w/o: 0.00/63475.96/0.00) lat (ms,95%): 0.20 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           1843006
        other:                           0
        total:                           1843006
    transactions:                        1843006 (61427.52 per sec.)
    queries:                             1843006 (61427.52 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0019s
    total number of events:              1843006

Latency (ms):
         min:                                    0.04
         avg:                                    0.13
         max:                                  156.09
         95th percentile:                        0.20
         sum:                               237854.64

Threads fairness:
    events (avg/stddev):           230375.7500/1236.44
    execution time (avg/stddev):   29.7318/0.00


sysbench mysql update index summary:
sysbench update_non_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 0
write: 1843006
other: 0
total: 1843006
transactions/s: 61427.52
queries/s: 61427.52
time: 30.0019s
min: 0.04
avg: 0.13
max: 156.09
95th: 0.20

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| update_non_index.lua | 1.0.14 | 8 | 0 | 1843006 | 0 | 1843006 | 61427.52 | 61427.52 | 30.0019s | 0.04 | 0.13 | 156.09 | 0.20 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
update_non_index.lua,1.0.14,8,0,1843006,0,1843006,61427.52,61427.52,30.0019s,0.04,0.13,156.09,0.20 

sysbench mysql cleanup database: sbt
sysbench update_non_index.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=30 --threads=8 --report-interval=1 --oltp-table-size=150000 --oltp-tables-count=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| update_non_index.lua | 1.0.14 | 8 | 0 | 1843006 | 0 | 1843006 | 61427.52 | 61427.52 | 30.0019s | 0.04 | 0.13 | 156.09 | 0.20 |


## sysbench mysql OLTP new read/write

```
./sysbench.sh mysqloltpnew

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest3'...
Creating table 'sbtest6'...
Creating table 'sbtest5'...
Creating table 'sbtest4'...
Creating table 'sbtest1'...
Creating table 'sbtest2'...
Creating table 'sbtest8'...
Creating table 'sbtest7'...
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest4'
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest8'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.05MB    | 0.00MB     | 0.05MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.16MB    | 0.00MB     | 0.16MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.17MB    | 0.00MB     | 0.17MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.08MB    | 0.00MB     | 0.08MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP new benchmark:
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from seed (1).


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 1913.32 qps: 38376.28 (r/w/o: 26885.36/7656.28/3834.63) lat (ms,95%): 5.00 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2278.30 qps: 45528.09 (r/w/o: 31858.26/9113.22/4556.61) lat (ms,95%): 5.00 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 2541.04 qps: 50834.78 (r/w/o: 35591.54/10161.15/5082.08) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 2613.93 qps: 52289.66 (r/w/o: 36606.06/10455.73/5227.87) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2690.02 qps: 53763.43 (r/w/o: 37621.30/10762.09/5380.04) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2692.99 qps: 53870.79 (r/w/o: 37714.85/10769.96/5385.98) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2716.03 qps: 54355.65 (r/w/o: 38055.45/10868.13/5432.06) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2741.01 qps: 54807.18 (r/w/o: 38362.12/10963.04/5482.02) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2779.97 qps: 55593.35 (r/w/o: 38907.54/11125.87/5559.93) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2865.08 qps: 57366.50 (r/w/o: 40153.05/11483.30/5730.15) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2704.98 qps: 54042.56 (r/w/o: 37835.69/10796.91/5409.96) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2771.00 qps: 55417.99 (r/w/o: 38800.99/11075.00/5542.00) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2780.92 qps: 55600.47 (r/w/o: 38914.93/11123.69/5561.85) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2804.08 qps: 56084.63 (r/w/o: 39261.14/11216.33/5607.16) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2782.96 qps: 55653.15 (r/w/o: 38952.40/11133.83/5566.91) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2900.06 qps: 58029.26 (r/w/o: 40629.88/11599.25/5800.13) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2848.96 qps: 56962.22 (r/w/o: 39869.45/11394.84/5697.92) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2861.03 qps: 57231.65 (r/w/o: 40059.46/11450.13/5722.07) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2863.94 qps: 57289.77 (r/w/o: 40112.14/11449.75/5727.88) lat (ms,95%): 3.62 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2909.04 qps: 58172.75 (r/w/o: 40718.52/11636.15/5818.07) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 2930.91 qps: 58610.13 (r/w/o: 41024.69/11723.63/5861.81) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 2928.21 qps: 58571.13 (r/w/o: 40998.89/11715.83/5856.41) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 2931.57 qps: 58654.32 (r/w/o: 41058.92/11732.26/5863.13) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 2830.32 qps: 56572.39 (r/w/o: 39594.47/11317.28/5660.64) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 2889.98 qps: 57790.56 (r/w/o: 40456.69/11554.91/5778.96) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 2937.00 qps: 58748.98 (r/w/o: 41125.98/11748.00/5875.00) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 2887.00 qps: 57737.04 (r/w/o: 40415.03/11548.01/5774.00) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 2876.02 qps: 57524.33 (r/w/o: 40268.23/11504.07/5752.03) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 2943.85 qps: 58857.98 (r/w/o: 41194.89/11775.39/5887.70) lat (ms,95%): 3.55 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 2897.66 qps: 57970.19 (r/w/o: 40581.23/11594.64/5794.32) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1163694
        write:                           332484
        other:                           166242
        total:                           1662420
    transactions:                        83121  (2770.21 per sec.)
    queries:                             1662420 (55404.28 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0042s
    total number of events:              83121

Latency (ms):
         min:                                    1.10
         avg:                                    2.89
         max:                                  132.76
         95th percentile:                        3.96
         sum:                               239865.00

Threads fairness:
    events (avg/stddev):           10390.1250/30.79
    execution time (avg/stddev):   29.9831/0.00


sysbench mysql OLTP new summary:
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1163694
write: 332484
other: 166242
total: 1662420
transactions/s: 2770.21
queries/s: 55404.28
time: 30.0042s
min: 1.10
avg: 2.89
max: 132.76
95th: 3.96

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_write.lua | 1.0.14 | 8 | 1163694 | 332484 | 166242 | 1662420 | 2770.21 | 55404.28 | 30.0042s | 1.10 | 2.89 | 132.76 | 3.96 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_read_write.lua,1.0.14,8,1163694,332484,166242,1662420,2770.21,55404.28,30.0042s,1.10,2.89,132.76,3.96 

sysbench mysql cleanup database: sbt
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_write.lua | 1.0.14 | 8 | 1163694 | 332484 | 166242 | 1662420 | 2770.21 | 55404.28 | 30.0042s | 1.10 | 2.89 | 132.76 | 3.96 |


## sysbench mysql OLTP new read only

```
./sysbench.sh mysqlreadonly-new

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest2'...
Creating table 'sbtest5'...
Creating table 'sbtest8'...
Creating table 'sbtest1'...
Creating table 'sbtest4'...
Creating table 'sbtest7'...
Creating table 'sbtest3'...
Creating table 'sbtest6'...
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest6'
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest7'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.11MB    | 0.00MB     | 0.11MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.09MB    | 0.00MB     | 0.09MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP read only new benchmark:
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from seed (1).


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2185.91 qps: 35053.39 (r/w/o: 30673.59/0.00/4379.80) lat (ms,95%): 7.04 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 1005.17 qps: 16051.65 (r/w/o: 14041.32/0.00/2010.33) lat (ms,95%): 13.22 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 633.00 qps: 10136.02 (r/w/o: 8870.02/0.00/1266.00) lat (ms,95%): 16.71 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 962.00 qps: 15418.95 (r/w/o: 13494.95/0.00/1923.99) lat (ms,95%): 17.95 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2404.01 qps: 38455.10 (r/w/o: 33647.08/0.00/4808.01) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2108.99 qps: 33731.85 (r/w/o: 29513.87/0.00/4217.98) lat (ms,95%): 4.57 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 1546.02 qps: 24755.30 (r/w/o: 21663.26/0.00/3092.04) lat (ms,95%): 6.79 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 1468.97 qps: 23488.54 (r/w/o: 20550.60/0.00/2937.94) lat (ms,95%): 6.79 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 1341.93 qps: 21471.94 (r/w/o: 18788.07/0.00/2683.87) lat (ms,95%): 7.43 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 1100.98 qps: 17614.72 (r/w/o: 15412.76/0.00/2201.97) lat (ms,95%): 9.73 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 1079.08 qps: 17263.33 (r/w/o: 15105.16/0.00/2158.17) lat (ms,95%): 10.65 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 1157.00 qps: 18499.05 (r/w/o: 16185.05/0.00/2314.01) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 1177.99 qps: 18851.79 (r/w/o: 16495.82/0.00/2355.97) lat (ms,95%): 8.28 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 1152.01 qps: 18442.10 (r/w/o: 16138.09/0.00/2304.01) lat (ms,95%): 8.74 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 1092.00 qps: 17461.01 (r/w/o: 15277.01/0.00/2184.00) lat (ms,95%): 10.27 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 1150.01 qps: 18411.09 (r/w/o: 16111.08/0.00/2300.01) lat (ms,95%): 8.74 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 1157.00 qps: 18486.07 (r/w/o: 16172.06/0.00/2314.01) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 1154.00 qps: 18480.02 (r/w/o: 16172.02/0.00/2308.00) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 1077.99 qps: 17261.80 (r/w/o: 15106.83/0.00/2154.98) lat (ms,95%): 9.73 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 1177.01 qps: 18836.24 (r/w/o: 16481.21/0.00/2355.03) lat (ms,95%): 8.28 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 1147.00 qps: 18362.03 (r/w/o: 16068.03/0.00/2294.00) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 1158.98 qps: 18526.76 (r/w/o: 16208.79/0.00/2317.97) lat (ms,95%): 8.43 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 1063.01 qps: 17010.09 (r/w/o: 14884.08/0.00/2126.01) lat (ms,95%): 9.56 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 1149.00 qps: 18381.93 (r/w/o: 16083.93/0.00/2297.99) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 1120.99 qps: 17929.83 (r/w/o: 15687.85/0.00/2241.98) lat (ms,95%): 8.74 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 1131.02 qps: 18109.25 (r/w/o: 15847.22/0.00/2262.03) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 1068.00 qps: 17090.02 (r/w/o: 14954.02/0.00/2136.00) lat (ms,95%): 9.39 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 1155.00 qps: 18448.97 (r/w/o: 16138.97/0.00/2310.00) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 1135.99 qps: 18204.77 (r/w/o: 15932.79/0.00/2271.97) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 1138.00 qps: 18211.99 (r/w/o: 15935.99/0.00/2276.00) lat (ms,95%): 8.74 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            523726
        write:                           0
        other:                           74818
        total:                           598544
    transactions:                        37409  (1246.69 per sec.)
    queries:                             598544 (19947.11 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0055s
    total number of events:              37409

Latency (ms):
         min:                                    1.54
         avg:                                    6.41
         max:                                   23.03
         95th percentile:                        9.56
         sum:                               239963.21

Threads fairness:
    events (avg/stddev):           4676.1250/11.34
    execution time (avg/stddev):   29.9954/0.00


sysbench mysql OLTP read only new summary:
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 523726
write: 0
other: 74818
total: 598544
transactions/s: 1246.69
queries/s: 19947.11
time: 30.0055s
min: 1.54
avg: 6.41
max: 23.03
95th: 9.56

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_only.lua | 1.0.14 | 8 | 523726 | 0 | 74818 | 598544 | 1246.69 | 19947.11 | 30.0055s | 1.54 | 6.41 | 23.03 | 9.56 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_read_only.lua,1.0.14,8,523726,0,74818,598544,1246.69,19947.11,30.0055s,1.54,6.41,23.03,9.56 

sysbench mysql cleanup database: sbt
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_only.lua | 1.0.14 | 8 | 523726 | 0 | 74818 | 598544 | 1246.69 | 19947.11 | 30.0055s | 1.54 | 6.41 | 23.03 | 9.56 |

## sysbench mysql OLTP new write only

```
./sysbench.sh mysqlwriteonly-new   

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest2'...Creating table 'sbtest3'...
Creating table 'sbtest1'...
Creating table 'sbtest7'...
Creating table 'sbtest8'...
Creating table 'sbtest6'...

Creating table 'sbtest5'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest1'
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest7'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.14MB    | 0.00MB     | 0.14MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.08MB    | 0.00MB     | 0.08MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.17MB    | 0.00MB     | 0.17MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.14MB    | 0.00MB     | 0.14MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP write only new benchmark:
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from seed (1).


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 6808.61 qps: 40874.61 (r/w/o: 0.00/27251.40/13623.21) lat (ms,95%): 1.86 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 10138.44 qps: 60829.61 (r/w/o: 0.00/40550.74/20278.87) lat (ms,95%): 1.27 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 11675.63 qps: 70052.81 (r/w/o: 0.00/46701.54/23351.27) lat (ms,95%): 1.01 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 12469.44 qps: 74819.61 (r/w/o: 0.00/49880.74/24938.87) lat (ms,95%): 0.99 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 13358.83 qps: 80148.97 (r/w/o: 0.00/53432.31/26716.66) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 13924.99 qps: 83548.94 (r/w/o: 0.00/55699.96/27848.98) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 13963.69 qps: 83780.16 (r/w/o: 0.00/55852.77/27927.39) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 14406.78 qps: 86449.66 (r/w/o: 0.00/57634.11/28815.55) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 13725.48 qps: 82345.87 (r/w/o: 0.00/54895.91/27449.96) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 14170.58 qps: 85023.45 (r/w/o: 0.00/56683.30/28340.15) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 14723.62 qps: 88339.75 (r/w/o: 0.00/58891.50/29448.25) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 14250.91 qps: 85505.44 (r/w/o: 0.00/57002.62/28502.81) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 14916.14 qps: 89500.81 (r/w/o: 0.00/59668.54/29832.27) lat (ms,95%): 0.81 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 14423.50 qps: 86543.01 (r/w/o: 0.00/57696.01/28847.00) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 15179.24 qps: 91073.41 (r/w/o: 0.00/60715.94/30357.47) lat (ms,95%): 0.81 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 14777.97 qps: 88671.82 (r/w/o: 0.00/59115.88/29555.94) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 14884.57 qps: 89298.44 (r/w/o: 0.00/59529.30/29769.15) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 14947.20 qps: 89688.19 (r/w/o: 0.00/59791.79/29896.40) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 14629.14 qps: 87766.86 (r/w/o: 0.00/58512.58/29254.29) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 14794.04 qps: 88775.25 (r/w/o: 0.00/59184.17/29591.08) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 14554.97 qps: 87314.80 (r/w/o: 0.00/58205.87/29108.93) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 13374.36 qps: 80257.16 (r/w/o: 0.00/53507.44/26749.72) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 13474.97 qps: 80852.84 (r/w/o: 0.00/53903.89/26948.95) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 14106.36 qps: 84638.18 (r/w/o: 0.00/56424.46/28213.73) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 14150.63 qps: 84907.78 (r/w/o: 0.00/56606.52/28301.26) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 15528.83 qps: 93165.96 (r/w/o: 0.00/62109.31/31056.65) lat (ms,95%): 0.77 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 14684.11 qps: 88109.66 (r/w/o: 0.00/58741.44/29368.22) lat (ms,95%): 0.81 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 15138.76 qps: 90838.57 (r/w/o: 0.00/60560.04/30278.52) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 15740.40 qps: 94451.43 (r/w/o: 0.00/62970.62/31480.81) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 14482.11 qps: 86881.66 (r/w/o: 0.00/57917.44/28964.22) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           1669696
        other:                           834848
        total:                           2504544
    transactions:                        417424 (13912.50 per sec.)
    queries:                             2504544 (83475.02 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0024s
    total number of events:              417424

Latency (ms):
         min:                                    0.15
         avg:                                    0.57
         max:                                  241.62
         95th percentile:                        0.87
         sum:                               239485.66

Threads fairness:
    events (avg/stddev):           52178.0000/194.86
    execution time (avg/stddev):   29.9357/0.00


sysbench mysql OLTP write only new summary:
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 0
write: 1669696
other: 834848
total: 2504544
transactions/s: 13912.50
queries/s: 83475.02
time: 30.0024s
min: 0.15
avg: 0.57
max: 241.62
95th: 0.87

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_write_only.lua | 1.0.14 | 8 | 0 | 1669696 | 834848 | 2504544 | 13912.50 | 83475.02 | 30.0024s | 0.15 | 0.57 | 241.62 | 0.87 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_write_only.lua,1.0.14,8,0,1669696,834848,2504544,13912.50,83475.02,30.0024s,0.15,0.57,241.62,0.87 

sysbench mysql cleanup database: sbt
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_write_only.lua | 1.0.14 | 8 | 0 | 1669696 | 834848 | 2504544 | 13912.50 | 83475.02 | 30.0024s | 0.15 | 0.57 | 241.62 | 0.87 |


## sysbench mysql OLTP new point select

```
./sysbench.sh mysqlpointselect-new

setup sbt database & user
mysqladmin create database: sbt

MySQL Buffers
aria_pagecache_buffer_size           1073741824
aria_sort_buffer_size                268435456
bulk_insert_buffer_size              8388608
innodb_buffer_pool_dump_at_shutdown  OFF
innodb_buffer_pool_dump_now          OFF
innodb_buffer_pool_dump_pct          100
innodb_buffer_pool_filename          ib_buffer_pool
innodb_buffer_pool_instances         8
innodb_buffer_pool_load_abort        OFF
innodb_buffer_pool_load_at_startup   OFF
innodb_buffer_pool_load_now          OFF
innodb_buffer_pool_populate          OFF
innodb_buffer_pool_size              8589934592
innodb_change_buffer_max_size        25
innodb_change_buffering              all
innodb_log_buffer_size               16777216
innodb_sort_buffer_size              2097152
join_buffer_size                     2097152
join_buffer_space_limit              2097152
key_buffer_size                      805306368
mrr_buffer_size                      262144
myisam_sort_buffer_size              805306368
net_buffer_length                    16384
optimizer_switch                     index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,index_merge_sort_intersection=off,engine_condition_pushdown=off,index_condition_pushdown=on,derived_merge=on,derived_with_keys=on,firstmatch=on,loosescan=on,materialization=on,in_to_exists=on,semijoin=on,partial_match_rowid_merge=on,partial_match_table_scan=on,subquery_cache=on,mrr=off,mrr_cost_based=off,mrr_sort_keys=off,outer_join_with_cache=on,semijoin_with_cache=on,join_cache_incremental=on,join_cache_hashed=on,join_cache_bka=on,optimize_join_buffer_size=off,table_elimination=on,extended_keys=on,exists_to_in=on,orderby_uses_equalities=off
preload_buffer_size                  32768
read_buffer_size                     2097152
read_rnd_buffer_size                 524288
sort_buffer_size                     2097152
sql_buffer_result                    OFF

MySQL Limits
aria_pagecache_division_limit         100
delayed_insert_limit                  100
expensive_subquery_limit              100
ft_query_expansion_limit              20
innodb_ft_result_cache_limit          2000000000
join_buffer_space_limit               2097152
key_cache_division_limit              100
log_slow_rate_limit                   1
min_examined_row_limit                0
open_files_limit                      262144
optimizer_selectivity_sampling_limit  100
query_cache_limit                     1572864
relay_log_space_limit                 0
sql_select_limit                      18446744073709551615
thread_pool_stall_limit               500
updatable_views_with_limit            YES

MySQL Maxes
aria_max_sort_file_size           9223372036853727232
extra_max_connections             1
ft_max_word_len                   84
group_concat_max_len              1024
innodb_adaptive_max_sleep_delay   150000
innodb_compression_pad_pct_max    50
innodb_file_format_max            Antelope
innodb_ft_max_token_size          84
innodb_io_capacity_max            2800
innodb_max_bitmap_file_size       104857600
innodb_max_changed_pages          1000000
innodb_max_dirty_pages_pct        75.000000
innodb_max_dirty_pages_pct_lwm    0.001000
innodb_max_purge_lag              0
innodb_max_purge_lag_delay        0
innodb_online_alter_log_max_size  134217728
max_allowed_packet                134217728
max_binlog_cache_size             18446744073709547520
max_binlog_size                   1073741824
max_binlog_stmt_cache_size        18446744073709547520
max_connect_errors                100000
max_connections                   1000
max_delayed_threads               20
max_digest_length                 1024
max_error_count                   64
max_heap_table_size               1073741824
max_insert_delayed_threads        20
max_join_size                     18446744073709551615
max_length_for_sort_data          1024
max_long_data_size                134217728
max_prepared_stmt_count           16382
max_relay_log_size                1073741824
max_seeks_for_key                 4294967295
max_session_mem_used              9223372036854775807
max_sort_length                   1024
max_sp_recursion_depth            0
max_statement_time                0.000000
max_tmp_tables                    32
max_user_connections              0
max_write_lock_count              4294967295
myisam_max_sort_file_size         8589934592
slave_max_allowed_packet          1073741824
slave_parallel_max_queued         131072
thread_pool_max_threads           1000
wsrep_max_ws_rows                 0
wsrep_max_ws_size                 2147483647

MySQL Concurrency
concurrent_insert           ALWAYS
innodb_commit_concurrency   0
innodb_concurrency_tickets  5000
innodb_thread_concurrency   0
thread_concurrency          10


sysbench prepare database: sbt
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest2'...
Creating table 'sbtest1'...Creating table 'sbtest7'...Creating table 'sbtest8'...


Creating table 'sbtest6'...
Creating table 'sbtest5'...
Creating table 'sbtest4'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest6'
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest6'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.22MB    | 0.00MB     | 0.22MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.09MB    | 0.00MB     | 0.09MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.09MB    | 0.00MB     | 0.09MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP POINT SELECT new benchmark:
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from seed (1).


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 43389.73 qps: 43389.73 (r/w/o: 43389.73/0.00/0.00) lat (ms,95%): 0.31 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 41192.95 qps: 41192.95 (r/w/o: 41192.95/0.00/0.00) lat (ms,95%): 0.33 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 40605.90 qps: 40605.90 (r/w/o: 40605.90/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 42872.53 qps: 42872.53 (r/w/o: 42872.53/0.00/0.00) lat (ms,95%): 0.33 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 38890.93 qps: 38890.93 (r/w/o: 38890.93/0.00/0.00) lat (ms,95%): 0.36 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 37956.76 qps: 37956.76 (r/w/o: 37956.76/0.00/0.00) lat (ms,95%): 0.37 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 38728.00 qps: 38728.00 (r/w/o: 38728.00/0.00/0.00) lat (ms,95%): 0.37 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 37816.34 qps: 37816.34 (r/w/o: 37816.34/0.00/0.00) lat (ms,95%): 0.37 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 39129.72 qps: 39129.72 (r/w/o: 39129.72/0.00/0.00) lat (ms,95%): 0.36 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 39281.00 qps: 39281.00 (r/w/o: 39281.00/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 39114.14 qps: 39114.14 (r/w/o: 39114.14/0.00/0.00) lat (ms,95%): 0.36 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 39182.91 qps: 39182.91 (r/w/o: 39182.91/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 39722.83 qps: 39722.83 (r/w/o: 39722.83/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 39455.21 qps: 39455.21 (r/w/o: 39455.21/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 39414.87 qps: 39414.87 (r/w/o: 39414.87/0.00/0.00) lat (ms,95%): 0.36 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 39756.00 qps: 39756.00 (r/w/o: 39756.00/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 39348.06 qps: 39348.06 (r/w/o: 39348.06/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 39475.18 qps: 39475.18 (r/w/o: 39475.18/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 39311.89 qps: 39311.89 (r/w/o: 39311.89/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 39366.87 qps: 39366.87 (r/w/o: 39366.87/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 39125.80 qps: 39125.80 (r/w/o: 39125.80/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 39444.62 qps: 39444.62 (r/w/o: 39444.62/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 39303.42 qps: 39303.42 (r/w/o: 39303.42/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 39503.27 qps: 39503.27 (r/w/o: 39503.27/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 39321.14 qps: 39321.14 (r/w/o: 39321.14/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 39561.81 qps: 39561.81 (r/w/o: 39561.81/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 39387.03 qps: 39387.03 (r/w/o: 39387.03/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 39803.44 qps: 39803.44 (r/w/o: 39803.44/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 39538.28 qps: 39538.28 (r/w/o: 39538.28/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1188739
        write:                           0
        other:                           0
        total:                           1188739
    transactions:                        1188739 (39621.15 per sec.)
    queries:                             1188739 (39621.15 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0016s
    total number of events:              1188739

Latency (ms):
         min:                                    0.01
         avg:                                    0.20
         max:                                   11.35
         95th percentile:                        0.35
         sum:                               239452.69

Threads fairness:
    events (avg/stddev):           148592.3750/162.21
    execution time (avg/stddev):   29.9316/0.00


sysbench mysql OLTP POINT SELECT new summary:
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1188739
write: 0
other: 0
total: 1188739
transactions/s: 39621.15
queries/s: 39621.15
time: 30.0016s
min: 0.01
avg: 0.20
max: 11.35
95th: 0.35

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_point_select.lua | 1.0.14 | 8 | 1188739 | 0 | 0 | 1188739 | 39621.15 | 39621.15 | 30.0016s | 0.01 | 0.20 | 11.35 | 0.35 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_point_select.lua,1.0.14,8,1188739,0,0,1188739,39621.15,39621.15,30.0016s,0.01,0.20,11.35,0.35 

sysbench mysql cleanup database: sbt
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
Dropping table 'sbtest5'...
Dropping table 'sbtest6'...
Dropping table 'sbtest7'...
Dropping table 'sbtest8'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_point_select.lua | 1.0.14 | 8 | 1188739 | 0 | 0 | 1188739 | 39621.15 | 39621.15 | 30.0016s | 0.01 | 0.20 | 11.35 | 0.35 |
