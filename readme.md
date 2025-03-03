# sysbench contents

* [sysbench.sh tool](#sysbenchsh-tool)
* [sysbench.sh notes](#sysbenchsh-notes)
* [sysbench.sh install](#sysbench-install)
* [sysbench.sh update](#sysbench-update)
* [sysbench.sh usage](#sysbench-usage)
* [sysbench cpu benchmark](#sysbench-cpu)
* [sysbench memory benchmark](#sysbench-memory)
* [sysbench fileio benchmark](#sysbench-fileio)
* [sysbench fileio fsync benchmark](#sysbench-fileio-fsync)
* [sysbench mysql read/write OLTP legacy benchmark](#sysbench-mysql-readwrite-oltp)
* [sysbench mysql read only OLTP legacy benchmark](#sysbench-mysql-read-only-oltp)
* [sysbench mysql INSERT legacy benchmark](#sysbench-mysql-insert)
* [sysbench mysql UPDATE INDEX legacy benchmark](#sysbench-mysql-update-index)
* [sysbench mysql UPDATE NON-INDEX legacy benchmark](#sysbench-mysql-update-nonindex)
* [sysbench mysql OLTP read/write new benchmark](#sysbench-mysql-oltp-new-readwrite)
* [sysbench mysql OLTP read only new benchmark](#sysbench-mysql-oltp-new-read-only)
* [sysbench mysql OLTP write only new benchmark](#sysbench-mysql-oltp-new-write-only)
* [sysbench mysql OLTP POINT SELECT new benchmark](#sysbench-mysql-oltp-new-point-select)
* [sysbench.sh logging](#sysbenchsh-logging)
* [sysbench.sh Ubuntu/Debian support](#sysbenchsh-ubuntudebian-support)
* [sysbench HTML report](#sysbench-html-report)

# sysbench.sh tool

`sysbench.sh` benchmark tool utilising [sysbench](https://github.com/akopytov/sysbench) currently maintained by [Alexey Kopytov](https://kaamos.me/blog/2016/03/08/towards-sysbench-1.0-history.html). The `sysbench.sh` script is written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing. Update: [sysbench.sh Ubuntu/Debian support](#sysbenchsh-ubuntudebian-support) has been added - only tested on Ubuntu 16.04/18.04 so far.

```
sysbench --version
sysbench 1.0.20
```

# sysbench.sh notes

* Results are displayed in 4 formats, standard, github markdown, CSV comma separated and newly added JSON format which also has standalone `--json` flag to only show JSON results.
* MySQL tests assume mysql root password is set in `/root/.my.cnf`

example `/root/.my.cnf` contents

```
[client]
user=root
password=YOUR_MYSQL_ROOT_PASSWORD
```

You can directly edit `sysbench.sh` settings for:

```
MYSQL_USER='sbtest'
MYSQL_PASS='sbtestpass'
MYSQL_DBNAME='sbt'
```

or leave `sysbench.sh` untouched and use a persistent `sysbench.ini` settings file which you can create and place in same directory as your `sysbench.sh` script

example `sysbench.ini` with variables overriding `sysbench.sh` ones:

```
MYSQL_USER='sbtest'
MYSQL_PASS='sbtestpass'
MYSQL_DBNAME='sbt'
MYSQL_THREADS=16
```

sysbench will switch to using jemalloc memory allocator instead of system default glibc if available (CentOS only right now)

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
Usage: ./sysbench.sh
  install
  install-source-el9
  update
  cpu
  mem
  fileio
  fileio-16k
  fileio-64k
  fileio-512k
  fileio-1m
  fileio-fsync
  fileio-fsync-16k
  mysql
  mysqlro
  mysqlinsert
  mysqlupdateindex
  mysqlupdatenonindex
  mysqloltpnew
  mysqlreadonly-new
  mysqlwriteonly-new
  mysqlpointselect-new
  tools
  baseinfo
  mysqlsettings
  --export-html [output_dir]

./sysbench.sh option [mysql ssl = y/n] [mysqlusername] [mysqlpassword] [mysqldbname]
./sysbench.sh mysql y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlro y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlinsert y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlupdateindex y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlupdatenonindex y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqloltpnew y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlreadonly-new y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlwriteonly-new y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh mysqlpointselect-new y|n mysqlusername mysqlpassword mysqldbname
./sysbench.sh all
```

## sysbench cpu

sysbench cpu tests test both single thread and max cpu core/thread count for comparison. Note: `sysbench.sh 2.3` reverted the `--cpu-max-prime=20000` parameter back to sysbench defaults `--cpu-max-prime=10000` so cpu events/sec values would be roughly 2x higher than prior `sysbench.sh cpu` tests.

sysbench 1.0.20 cpu benchmark using `--cpu-max-prime=10000`

```
./sysbench.sh cpu
-------------------------------------------
System Information
-------------------------------------------
4.18.0-425.19.2.el8_7.x86_64

AlmaLinux release 8.10 (Cerulean Leopard)

Centmin Mod 140.00beta01.b200

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             4712.927
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4900.0000 800.0000
1   0    0      1    1:1:1:0       yes    4900.0000 800.0000
2   0    0      2    2:2:2:0       yes    4900.0000 800.0000
3   0    0      3    3:3:3:0       yes    4900.0000 800.0000
4   0    0      4    4:4:4:0       yes    4900.0000 800.0000
5   0    0      5    5:5:5:0       yes    4900.0000 800.0000
6   0    0      0    0:0:0:0       yes    4900.0000 800.0000
7   0    0      1    1:1:1:0       yes    4900.0000 800.0000
8   0    0      2    2:2:2:0       yes    4900.0000 800.0000
9   0    0      3    3:3:3:0       yes    4900.0000 800.0000
10  0    0      4    4:4:4:0       yes    4900.0000 800.0000
11  0    0      5    5:5:5:0       yes    4900.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31812       15788        6699          55        9324       15430
Low:          31812       25112        6699
High:             0           0           0
Swap:         32767       17252       15515
Total:        64580       33040       22215

Filesystem        Type          Size  Used Avail Use% Mounted on
devtmpfs          devtmpfs       16G     0   16G   0% /dev
tmpfs             tmpfs          16G  4.0K   16G   1% /dev/shm
tmpfs             tmpfs          16G  1.7G   14G  11% /run
tmpfs             tmpfs          16G     0   16G   0% /sys/fs/cgroup
/dev/md1          ext4          875G  408G  423G  50% /
/dev/md0          vfat          500M  5.9M  494M   2% /boot/efi
tmpfs             tmpfs         3.2G     0  3.2G   0% /run/user/0
tmpfs             tmpfs          16G  1.7M   16G   1% /tmp
JuiceFS:myjuicefs fuse.juicefs  1.0P   21M  1.0P   1% /home/juicefs_mount


sysbench cpu --cpu-max-prime=10000 --threads=1 run
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
prime: 10000
events/s: 1618.30
time: 10.0002s
min: 0.60
avg: 0.62
max: 1.40
95th: 0.65

{"key":"sysbench","value":"1.0.20"}
{"key":"threads:","value":"1"}
{"key":"events/s:","value":"1618.30"}
{"key":"time:","value":"10.0002s"}
{"key":"min:","value":"0.60"}
{"key":"avg:","value":"0.62"}
{"key":"max:","value":"1.40"}
{"key":"95th:","value":"0.65"}

# CPU Benchmark (Single Thread)

| Metric | Value |
|--------|-------|
| threads: | 1 |
| prime: | 10000 |
| events/s: | 1618.30 |
| time: | 10.0002s |
| min: | 0.60 |
| avg: | 0.62 |
| max: | 1.40 |
| 95th: | 0.65 |

threads:,1
prime:,10000
events/s:,1618.30
time:,10.0002s
min:,0.60
avg:,0.62
max:,1.40
95th:,0.65

sysbench cpu --cpu-max-prime=10000 --threads=12 run
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
threads: 12
prime: 10000
events/s: 14701.35
time: 10.0008s
min: 0.73
avg: 0.82
max: 18.18
95th: 0.81

{"key":"sysbench","value":"1.0.20"}
{"key":"threads:","value":"12"}
{"key":"events/s:","value":"14701.35"}
{"key":"time:","value":"10.0008s"}
{"key":"min:","value":"0.73"}
{"key":"avg:","value":"0.82"}
{"key":"max:","value":"18.18"}
{"key":"95th:","value":"0.81"}

# CPU Benchmark (12 Threads)

| Metric | Value |
|--------|-------|
| threads: | 12 |
| prime: | 10000 |
| events/s: | 14701.35 |
| time: | 10.0008s |
| min: | 0.73 |
| avg: | 0.82 |
| max: | 18.18 |
| 95th: | 0.81 |


| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.20 | 1 | 1618.30 | 10.0002s | 0.60 | 0.62 | 1.40 | 0.65 |
| 1.0.20 | 12 | 14701.35 | 10.0008s | 0.73 | 0.82 | 18.18 | 0.81 |

threads:,12
prime:,10000
events/s:,14701.35
time:,10.0008s
min:,0.73
avg:,0.82
max:,18.18
95th:,0.81
```

Markdown results table

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.20 | 1 | 1618.30 | 10.0002s | 0.60 | 0.62 | 1.40 | 0.65 |
| 1.0.20 | 12 | 14701.35 | 10.0008s | 0.73 | 0.82 | 18.18 | 0.81 |


## sysbench memory

sysbench memory tests test both single thread and max cpu core/thread count for comparison

```
./sysbench.sh mem
-------------------------------------------
System Information
-------------------------------------------
4.18.0-425.19.2.el8_7.x86_64

AlmaLinux release 8.10 (Cerulean Leopard)

Centmin Mod 140.00beta01.b200

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             3800.000
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4900.0000 800.0000
1   0    0      1    1:1:1:0       yes    4900.0000 800.0000
2   0    0      2    2:2:2:0       yes    4900.0000 800.0000
3   0    0      3    3:3:3:0       yes    4900.0000 800.0000
4   0    0      4    4:4:4:0       yes    4900.0000 800.0000
5   0    0      5    5:5:5:0       yes    4900.0000 800.0000
6   0    0      0    0:0:0:0       yes    4900.0000 800.0000
7   0    0      1    1:1:1:0       yes    4900.0000 800.0000
8   0    0      2    2:2:2:0       yes    4900.0000 800.0000
9   0    0      3    3:3:3:0       yes    4900.0000 800.0000
10  0    0      4    4:4:4:0       yes    4900.0000 800.0000
11  0    0      5    5:5:5:0       yes    4900.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31812       15786        6701          55        9324       15431
Low:          31812       25111        6701
High:             0           0           0
Swap:         32767       17252       15515
Total:        64580       33039       22216

Filesystem        Type          Size  Used Avail Use% Mounted on
devtmpfs          devtmpfs       16G     0   16G   0% /dev
tmpfs             tmpfs          16G  4.0K   16G   1% /dev/shm
tmpfs             tmpfs          16G  1.7G   14G  11% /run
tmpfs             tmpfs          16G     0   16G   0% /sys/fs/cgroup
/dev/md1          ext4          875G  408G  423G  50% /
/dev/md0          vfat          500M  5.9M  494M   2% /boot/efi
tmpfs             tmpfs         3.2G     0  3.2G   0% /run/user/0
tmpfs             tmpfs          16G  1.7M   16G   1% /tmp
JuiceFS:myjuicefs fuse.juicefs  1.0P   21M  1.0P   1% /home/juicefs_mount


sysbench memory --memory-block-size=1K --memory-total-size=1G --threads=1 run
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
1024.00 MiB transfer (6934.23 MiB/sec)
time: 0.1466s
min: 0.00
avg: 0.00
max: 0.03
95th: 0.00

{"key":"threads:","value":"1"}
{"key":"transfer","value":"6934.23"}
{"key":"time:","value":"0.1466s"}
{"key":"min:","value":"0.00"}
{"key":"avg:","value":"0.00"}
{"key":"max:","value":"0.03"}
{"key":"95th:","value":"0.00"}

# Memory Benchmark (Single Thread)

| Metric | Value |
|--------|-------|
| threads: | 1 |
| transfer | 6934.23 MiB/sec |
| time: | 0.1466s |
| min: | 0.00 |
| avg: | 0.00 |
| max: | 0.03 |
| 95th: | 0.00 |


sysbench memory --memory-block-size=1K --memory-total-size=1G --threads=12 run
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
threads: 12
1024.00 MiB transfer (22783.17 MiB/sec)
time: 0.0438s
min: 0.00
avg: 0.00
max: 3.34
95th: 0.00

{"key":"threads:","value":"12"}
{"key":"transfer","value":"22783.17"}
{"key":"time:","value":"0.0438s"}
{"key":"min:","value":"0.00"}
{"key":"avg:","value":"0.00"}
{"key":"max:","value":"3.34"}
{"key":"95th:","value":"0.00"}

# Memory Benchmark (12 Threads)

| Metric | Value |
|--------|-------|
| threads: | 12 |
| transfer | 22783.17 MiB/sec |
| time: | 0.0438s |
| min: | 0.00 |
| avg: | 0.00 |
| max: | 3.34 |
| 95th: | 0.00 |


| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.20 | 1 | 1KKiB | 1024MiBMiB | read | 1048576 | 6934.23 | 0.1466s | 0.00 | 0.00 | 0.03 | 0.00 |
| memory | 1.0.20 | 12 | 1KKiB | 1024MiBMiB | read | 1048576 | 22783.17 | 0.0438s | 0.00 | 0.00 | 3.34 | 0.00 |

threads:,12
transfer,22783.17 MiB/sec
time:,0.0438s
min:,0.00
avg:,0.00
max:,3.34
95th:,0.00
```

Markdown results table

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.20 | 1 | 1KKiB | 1024MiBMiB | read | 1048576 | 6934.23 | 0.1466s | 0.00 | 0.00 | 0.03 | 0.00 |
| memory | 1.0.20 | 12 | 1KKiB | 1024MiBMiB | read | 1048576 | 22783.17 | 0.0438s | 0.00 | 0.00 | 3.34 | 0.00 |

## sysbench fileio

sysbench fileio disk performance tests are conducted in directory `/home/sysbench/fileio` with the presumption that `/home` partition is usually the largest disk free space partition on the server to ensure you don't run out of disk space. This fileio test tests both single thread and max cpu core/thread count for comparison using a 2048MB file size.

The default test uses 4K (4096 bytes) block size, though with `sysbench.sh 2.1`, you can now also test with 16K, 64K, 512K, and 1M block sizes. Testing 16K block size would be closest to MySQL InnoDB database table's default 16K page size.

```
./sysbench.sh fileio
./sysbench.sh fileio-16k
./sysbench.sh fileio-64k
./sysbench.sh fileio-512k
./sysbench.sh fileio-1m
```

```
./sysbench.sh fileio
-------------------------------------------
System Information
-------------------------------------------
4.18.0-425.19.2.el8_7.x86_64

AlmaLinux release 8.10 (Cerulean Leopard)

Centmin Mod 140.00beta01.b200

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             3800.000
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4900.0000 800.0000
1   0    0      1    1:1:1:0       yes    4900.0000 800.0000
2   0    0      2    2:2:2:0       yes    4900.0000 800.0000
3   0    0      3    3:3:3:0       yes    4900.0000 800.0000
4   0    0      4    4:4:4:0       yes    4900.0000 800.0000
5   0    0      5    5:5:5:0       yes    4900.0000 800.0000
6   0    0      0    0:0:0:0       yes    4900.0000 800.0000
7   0    0      1    1:1:1:0       yes    4900.0000 800.0000
8   0    0      2    2:2:2:0       yes    4900.0000 800.0000
9   0    0      3    3:3:3:0       yes    4900.0000 800.0000
10  0    0      4    4:4:4:0       yes    4900.0000 800.0000
11  0    0      5    5:5:5:0       yes    4900.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31812       15786        6701          55        9324       15431
Low:          31812       25111        6701
High:             0           0           0
Swap:         32767       17252       15515
Total:        64580       33038       22217

Filesystem        Type          Size  Used Avail Use% Mounted on
devtmpfs          devtmpfs       16G     0   16G   0% /dev
tmpfs             tmpfs          16G  4.0K   16G   1% /dev/shm
tmpfs             tmpfs          16G  1.7G   14G  11% /run
tmpfs             tmpfs          16G     0   16G   0% /sys/fs/cgroup
/dev/md1          ext4          875G  408G  423G  50% /
/dev/md0          vfat          500M  5.9M  494M   2% /boot/efi
tmpfs             tmpfs         3.2G     0  3.2G   0% /run/user/0
tmpfs             tmpfs          16G  1.7M   16G   1% /tmp
JuiceFS:myjuicefs fuse.juicefs  1.0P   21M  1.0P   1% /home/juicefs_mount


sysbench fileio --file-num=128 --file-total-size=15906M --file-test-mode=seqwr --file-extra-flags=direct --file-block-size=4096 --file-io-mode=sync --time=10 prepare
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
    reads/s:                      0.00
    writes/s:                     39576.28
    fsyncs/s:                     50667.23
    total time:                          10.0005s

{"key":"reads/s:","value":"0.00"}
{"key":"writes/s:","value":"39576.28"}
{"key":"fsyncs/s:","value":"50667.23"}
{"key":"total","value":"time:"}

# File I/O Benchmark (seqwr-default)

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 0.00 | 39576.28 | 50667.23 | N/A | N/A | 10.0005s | N/A | N/A | N/A | N/A |

reads/s:,0.00
writes/s:,39576.28
fsyncs/s:,50667.23
total,time:
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Removing test files...
```

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 0.00 | 39576.28 | 50667.23 | N/A | N/A | 10.0005s | N/A | N/A | N/A | N/A |

## sysbench fileio fsync

Added sysbench.sh fileio fsync benchmark as outlined [here](https://www.percona.com/blog/2018/07/18/why-consumer-ssd-reviews-are-useless-for-database-performance-use-case/). Test duration is controlled by variable `FILEIO_FSYNCTIME='30'` which is set to 30 seconds default.

The default test uses 4K (4096 bytes) block size, though with `sysbench.sh 2.2`, you can now also test with 16K block sizes. Testing 16K block size would be closest to MySQL InnoDB database table's default 16K page size.

```
./sysbench.sh fileio-fsync
./sysbench.sh fileio-fsync-16k
```

```
./sysbench.sh fileio-fsync
-------------------------------------------
System Information
-------------------------------------------
4.18.0-425.19.2.el8_7.x86_64

AlmaLinux release 8.10 (Cerulean Leopard)

Centmin Mod 140.00beta01.b200

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             3800.000
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4900.0000 800.0000
1   0    0      1    1:1:1:0       yes    4900.0000 800.0000
2   0    0      2    2:2:2:0       yes    4900.0000 800.0000
3   0    0      3    3:3:3:0       yes    4900.0000 800.0000
4   0    0      4    4:4:4:0       yes    4900.0000 800.0000
5   0    0      5    5:5:5:0       yes    4900.0000 800.0000
6   0    0      0    0:0:0:0       yes    4900.0000 800.0000
7   0    0      1    1:1:1:0       yes    4900.0000 800.0000
8   0    0      2    2:2:2:0       yes    4900.0000 800.0000
9   0    0      3    3:3:3:0       yes    4900.0000 800.0000
10  0    0      4    4:4:4:0       yes    4900.0000 800.0000
11  0    0      5    5:5:5:0       yes    4900.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31812       15785        6687          56        9339       15433
Low:          31812       25124        6687
High:             0           0           0
Swap:         32767       17252       15515
Total:        64580       33037       22203

Filesystem        Type          Size  Used Avail Use% Mounted on
devtmpfs          devtmpfs       16G     0   16G   0% /dev
tmpfs             tmpfs          16G  4.0K   16G   1% /dev/shm
tmpfs             tmpfs          16G  1.7G   14G  11% /run
tmpfs             tmpfs          16G     0   16G   0% /sys/fs/cgroup
/dev/md1          ext4          875G  408G  423G  50% /
/dev/md0          vfat          500M  5.9M  494M   2% /boot/efi
tmpfs             tmpfs         3.2G     0  3.2G   0% /run/user/0
tmpfs             tmpfs          16G  1.7M   16G   1% /tmp
JuiceFS:myjuicefs fuse.juicefs  1.0P   21M  1.0P   1% /home/juicefs_mount


sysbench fileio --file-num=1 --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --time=30 prepare
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
    reads/s:                      0.00
    writes/s:                     40566.48
    fsyncs/s:                     40566.48
    total time:                          30.0001s

{"key":"reads/s:","value":"0.00"}
{"key":"writes/s:","value":"40566.48"}
{"key":"fsyncs/s:","value":"40566.48"}
{"key":"total","value":"time:"}

# File I/O Benchmark (fsync-default)

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 0.00 | 40566.48 | 40566.48 | N/A | N/A | 30.0001s | N/A | N/A | N/A | N/A |

reads/s:,0.00
writes/s:,40566.48
fsyncs/s:,40566.48
total,time:
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Removing test files...
```

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 0.00 | 40566.48 | 40566.48 | N/A | N/A | 30.0001s | N/A | N/A | N/A | N/A |


## sysbench mysql OLTP new read/write

```
./sysbench.sh mysqloltpnew
-------------------------------------------
System Information
-------------------------------------------
4.18.0-425.19.2.el8_7.x86_64

AlmaLinux release 8.10 (Cerulean Leopard)

Centmin Mod 140.00beta01.b200

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             3800.000
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities

CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE MAXMHZ    MINMHZ
0   0    0      0    0:0:0:0       yes    4900.0000 800.0000
1   0    0      1    1:1:1:0       yes    4900.0000 800.0000
2   0    0      2    2:2:2:0       yes    4900.0000 800.0000
3   0    0      3    3:3:3:0       yes    4900.0000 800.0000
4   0    0      4    4:4:4:0       yes    4900.0000 800.0000
5   0    0      5    5:5:5:0       yes    4900.0000 800.0000
6   0    0      0    0:0:0:0       yes    4900.0000 800.0000
7   0    0      1    1:1:1:0       yes    4900.0000 800.0000
8   0    0      2    2:2:2:0       yes    4900.0000 800.0000
9   0    0      3    3:3:3:0       yes    4900.0000 800.0000
10  0    0      4    4:4:4:0       yes    4900.0000 800.0000
11  0    0      5    5:5:5:0       yes    4900.0000 800.0000

              total        used        free      shared  buff/cache   available
Mem:          31812       15785        6635          56        9391       15448
Low:          31812       25177        6635
High:             0           0           0
Swap:         32767       17252       15515
Total:        64580       33037       22151

Filesystem        Type          Size  Used Avail Use% Mounted on
devtmpfs          devtmpfs       16G     0   16G   0% /dev
tmpfs             tmpfs          16G  4.0K   16G   1% /dev/shm
tmpfs             tmpfs          16G  1.7G   14G  11% /run
tmpfs             tmpfs          16G     0   16G   0% /sys/fs/cgroup
/dev/md1          ext4          875G  408G  423G  50% /
/dev/md0          vfat          500M  5.9M  494M   2% /boot/efi
tmpfs             tmpfs         3.2G     0  3.2G   0% /run/user/0
tmpfs             tmpfs          16G  1.7M   16G   1% /tmp
JuiceFS:myjuicefs fuse.juicefs  1.0P   21M  1.0P   1% /home/juicefs_mount



Setting up sbt database & user (2.8 style)
Creating database: sbt
sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --tables=8 --table-size=150000 --threads=12 --time=30 --report-interval=2 prepare
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest4'...
Creating table 'sbtest1'...
Creating table 'sbtest6'...
Creating table 'sbtest7'...
Creating table 'sbtest2'...
Creating table 'sbtest5'...
Creating table 'sbtest8'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest1'
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest8'...

sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)
threads: 12
read: 1717324
write: 490664
other: 245332
total: 2453320
transactions: 122666 (4087.95 per sec.)
queries: 2453320 (81758.91 per sec.)
time: 30.0057s
min: 1.09
avg: 2.93
max: 24.00
95th: 3.96

{"key":"threads:","value":"12"}
{"key":"read:","value":"1717324"}
{"key":"write:","value":"490664"}
{"key":"other:","value":"245332"}
{"key":"total:","value":"2453320"}
{"key":"transactions:","value":"122666"}
{"key":"queries:","value":"2453320"}
{"key":"time:","value":"30.0057s"}
{"key":"min:","value":"1.09"}
{"key":"avg:","value":"2.93"}
{"key":"max:","value":"24.00"}
{"key":"95th:","value":"3.96"}

# MySQL OLTP New Benchmark

| Metric | Value |
|--------|-------|
| threads: | 12 |
| read: | 1717324 |
| write: | 490664 |
| other: | 245332 |
| total: | 2453320 |
| transactions: | 122666 |
| queries: | 2453320 |
| time: | 30.0057s |
| min: | 1.09 |
| avg: | 2.93 |
| max: | 24.00 |
| 95th: | 3.96 |

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_write | /usr/share/sysbench/oltp_read_write.lua | 12 | 1717324 | 490664 | 245332 | 2453320 | 4087.95 | 81758.91 | 30.0057s | 1.09 | 2.93 | 24.00 | 3.96 |

threads:,12
read:,1717324
write:,490664
other:,245332
total:,2453320
transactions:,122666
queries:,2453320
time:,30.0057s
min:,1.09
avg:,2.93
max:,24.00
95th:,3.96

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th
oltp_read_write,/usr/share/sysbench/oltp_read_write.lua,12,1717324,490664,245332,2453320,4087.95,81758.91,30.0057s,1.09,2.93,24.00,3.96
sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

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
| oltp_read_write | /usr/share/sysbench/oltp_read_write.lua | 12 | 1717324 | 490664 | 245332 | 2453320 | 4087.95 | 81758.91 | 30.0057s | 1.09 | 2.93 | 24.00 | 3.96 |

# sysbench.sh logging

Each `sysbench.sh` test option saves results into temporary log file in `/home/sysbench/` directory which gets overwritten after each script run.

```
ls -lh /home/sysbench/ | grep Mar
-rw-r--r-- 1 root root 537K Mar  3 10:23 diskstats-mysqloltp_new.log
drwxr-xr-x 2 root root 4.0K Mar  3 10:20 fileio
-rw-r--r-- 1 root root  219 Mar  3 10:20 fileio_fsync-default.json
-rw-r--r-- 1 root root  219 Mar  3 10:15 fileio_seqwr-default.json
-rw-r--r-- 1 root root 244K Mar  3 10:22 mysqlstats-mysqloltp_new.log
-rw-r--r-- 1 root root 1.3M Mar  3 10:23 pidstat-mysqloltp_new.log
-rw-r--r-- 1 root root  101 Mar  3 10:11 sysbench-cpu-threads-12.csv
-rw-r--r-- 1 root root  411 Mar  3 10:11 sysbench-cpu-threads-12.json
-rw-r--r-- 1 root root  204 Mar  3 10:11 sysbench-cpu-threads-12.log
-rw-r--r-- 1 root root  217 Mar  3 10:11 sysbench-cpu-threads-12.md
-rw-r--r-- 1 root root   98 Mar  3 10:11 sysbench-cpu-threads-1.csv
-rw-r--r-- 1 root root  408 Mar  3 10:11 sysbench-cpu-threads-1.json
-rw-r--r-- 1 root root  200 Mar  3 10:11 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  217 Mar  3 10:11 sysbench-cpu-threads-1.md
-rw-r--r-- 1 root root   64 Mar  3 10:20 sysbench-fileio-fsync-default.csv
-rw-r--r-- 1 root root  226 Mar  3 10:20 sysbench-fileio-fsync-default.log
-rw-r--r-- 1 root root  437 Mar  3 10:20 sysbench-fileio-fsync-default.md
-rw-r--r-- 1 root root   64 Mar  3 10:15 sysbench-fileio-seqwr-default.csv
-rw-r--r-- 1 root root  226 Mar  3 10:15 sysbench-fileio-seqwr-default.log
-rw-r--r-- 1 root root  437 Mar  3 10:15 sysbench-fileio-seqwr-default.md
-rw-r--r-- 1 root root   93 Mar  3 10:12 sysbench-mem-threads-12.csv
-rw-r--r-- 1 root root  354 Mar  3 10:12 sysbench-mem-threads-12.json
-rw-r--r-- 1 root root  237 Mar  3 10:12 sysbench-mem-threads-12.log
-rw-r--r-- 1 root root  206 Mar  3 10:12 sysbench-mem-threads-12.md
-rw-r--r-- 1 root root   91 Mar  3 10:12 sysbench-mem-threads-1.csv
-rw-r--r-- 1 root root  352 Mar  3 10:12 sysbench-mem-threads-1.json
-rw-r--r-- 1 root root  234 Mar  3 10:12 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  207 Mar  3 10:12 sysbench-mem-threads-1.md
-rw-r--r-- 1 root root  164 Mar  3 10:22 sysbench-mysqloltp_new.csv
-rw-r--r-- 1 root root  232 Mar  3 10:22 sysbench-mysqloltp_new-full.csv
-rw-r--r-- 1 root root  623 Mar  3 10:22 sysbench-mysqloltp_new.json
-rw-r--r-- 1 root root  530 Mar  3 10:22 sysbench-mysqloltp_new.log
-rw-r--r-- 1 root root  699 Mar  3 10:22 sysbench-mysqloltp_new.md
```

# sysbench.sh Ubuntu/Debian support

Add experimental Ubuntu/Debian support to at least be able to install/upgrade via `apt` and run some benchmarks

sysbench cpu benchmark

```
./sysbench.sh cpu
-------------------------------------------
System Information
-------------------------------------------

4.15.0-22-generic

DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=18.04
DISTRIB_CODENAME=bionic
DISTRIB_DESCRIPTION="Ubuntu 18.04 LTS"

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              4
On-line CPU(s) list: 0-3
Thread(s) per core:  1
Core(s) per socket:  4
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               94
Model name:          Intel Core Processor (Skylake, IBRS)
Stepping:            3
CPU MHz:             2099.998
BogoMIPS:            4199.99
Hypervisor vendor:   KVM
Virtualization type: full
L1d cache:           32K
L1i cache:           32K
L2 cache:            4096K
NUMA node0 CPU(s):   0-3
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 ibpb ibrs

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 ibpb ibrs

CPU NODE SOCKET CORE L1d:L1i:L2 ONLINE
0   0    0      0    0:0:0      yes
1   0    0      1    1:1:1      yes
2   0    0      2    2:2:2      yes
3   0    0      3    3:3:3      yes

              total        used        free      shared  buff/cache   available
Mem:          16040          68       15566         100         405       15971
Low:          16040         473       15566
High:             0           0           0
Swap:             0           0           0

Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-root   79G   56G   19G  76% /
none                         492K     0  492K   0% /dev
udev                         7.9G     0  7.9G   0% /dev/tty
tmpfs                        100K     0  100K   0% /dev/lxd
tmpfs                        100K     0  100K   0% /dev/.lxd-mounts
tmpfs                        7.9G     0  7.9G   0% /dev/shm
tmpfs                        7.9G  140K  7.9G   1% /run
tmpfs                        5.0M     0  5.0M   0% /run/lock
tmpfs                        7.9G     0  7.9G   0% /sys/fs/cgroup


sysbench cpu --cpu-max-prime=20000 --threads=1 run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
prime: 20000
events/s: 318.30
time: 10.0008s
min: 2.59
avg: 3.14
max: 27.03
95th: 4.33

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.11 | 1 | 318.30 | 10.0008s | 2.59 | 3.14 | 27.03 | 4.33 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.11,1,318.30,10.0008s,2.59,3.14,27.03,4.33 

sysbench cpu --cpu-max-prime=20000 --threads=4 run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
prime: 20000
events/s: 1208.10
time: 10.0055s
min: 2.59
avg: 3.31
max: 30.62
95th: 4.65

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.11 | 4 | 1208.10 | 10.0055s | 2.59 | 3.31 | 30.62 | 4.65 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.11,4,1208.10,10.0055s,2.59,3.31,30.62,4.65 
```

sysbench memory

```
./sysbench.sh mem
-------------------------------------------
System Information
-------------------------------------------

4.15.0-22-generic

DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=18.04
DISTRIB_CODENAME=bionic
DISTRIB_DESCRIPTION="Ubuntu 18.04 LTS"

Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              4
On-line CPU(s) list: 0-3
Thread(s) per core:  1
Core(s) per socket:  4
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
CPU family:          6
Model:               94
Model name:          Intel Core Processor (Skylake, IBRS)
Stepping:            3
CPU MHz:             2099.998
BogoMIPS:            4199.99
Hypervisor vendor:   KVM
Virtualization type: full
L1d cache:           32K
L1i cache:           32K
L2 cache:            4096K
NUMA node0 CPU(s):   0-3
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 ibpb ibrs

CPU Flags
 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology cpuid pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 ibpb ibrs

CPU NODE SOCKET CORE L1d:L1i:L2 ONLINE
0   0    0      0    0:0:0      yes
1   0    0      1    1:1:1      yes
2   0    0      2    2:2:2      yes
3   0    0      3    3:3:3      yes

              total        used        free      shared  buff/cache   available
Mem:          16040          68       15566         100         405       15972
Low:          16040         473       15566
High:             0           0           0
Swap:             0           0           0

Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-root   79G   56G   19G  76% /
none                         492K     0  492K   0% /dev
udev                         7.9G     0  7.9G   0% /dev/tty
tmpfs                        100K     0  100K   0% /dev/lxd
tmpfs                        100K     0  100K   0% /dev/.lxd-mounts
tmpfs                        7.9G     0  7.9G   0% /dev/shm
tmpfs                        7.9G  140K  7.9G   1% /run
tmpfs                        5.0M     0  5.0M   0% /run/lock
tmpfs                        7.9G     0  7.9G   0% /sys/fs/cgroup


sysbench memory --threads=1 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (4147620.49 per second)
transferred (4050.41 MiB/sec)
time: 0.2504s
min: 0.00
avg: 0.00
max: 0.17
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.11 | 1 | 1KiB | 1024MiB | read | 1048576 | 4050.41 | 0.2504s | 0.00 | 0.00 | 0.17 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.11,1,1KiB,1024MiB,read,1048576,4050.41,0.2504s,0.00,0.00,0.17,0.00 

sysbench memory --threads=4 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (10577460.77 per second)
transferred (10329.55 MiB/sec)
time: 0.0971s
min: 0.00
avg: 0.00
max: 0.17
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.11 | 4 | 1KiB | 1024MiB | read | 1048576 | 10329.55 | 0.0971s | 0.00 | 0.00 | 0.17 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.11,4,1KiB,1024MiB,read,1048576,10329.55,0.0971s,0.00,0.00,0.17,0.00 
```

sysbench fileio

```
./sysbench.sh file

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqrd prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqrd-threads-1-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 4045.57
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 15.80
written-MiB/s: 0.00
time: 10.0003s
min: 0.08
avg: 0.25
max: 48.10
95th: 0.49

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 1 | 4KiB | I/O | read | 4045.57 | 0.00 | 0.00 | 15.80 | 0.00 | 10.0003s | 0.08 | 0.25 | 48.10 | 0.49 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,1,4KiB,I/O,read,4045.57,0.00,0.00,15.80,0.00,10.0003s,0.08,0.25,48.10,0.49 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqwr prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqwr-threads-1-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 1919.47
fsyncs/s: 2446.13
read-MiB/s: 0.00
written-MiB/s: 7.50
time: 10.0002s
min: 0.03
avg: 0.23
max: 37.70
95th: 0.46

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 1 | 4KiB | I/O | write | 0.00 | 1919.47 | 2446.13 | 0.00 | 7.50 | 10.0002s | 0.03 | 0.23 | 37.70 | 0.46 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,1,4KiB,I/O,write,0.00,1919.47,2446.13,0.00,7.50,10.0002s,0.03,0.23,37.70,0.46 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndrd prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndrd-threads-1-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 2916.12
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 11.39
written-MiB/s: 0.00
time: 10.0005s
min: 0.08
avg: 0.34
max: 41.85
95th: 0.58

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 1 | 4KiB | I/O | read | 2916.12 | 0.00 | 0.00 | 11.39 | 0.00 | 10.0005s | 0.08 | 0.34 | 41.85 | 0.58 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,1,4KiB,I/O,read,2916.12,0.00,0.00,11.39,0.00,10.0005s,0.08,0.34,41.85,0.58 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndwr prepare

sysbench fileio --threads=1 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndwr-threads-1-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 3141.23
fsyncs/s: 4018.34
read-MiB/s: 0.00
written-MiB/s: 12.27
time: 10.0002s
min: 0.03
avg: 0.14
max: 28.22
95th: 0.30

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 1 | 4KiB | I/O | write | 0.00 | 3141.23 | 4018.34 | 0.00 | 12.27 | 10.0002s | 0.03 | 0.14 | 28.22 | 0.30 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,1,4KiB,I/O,write,0.00,3141.23,4018.34,0.00,12.27,10.0002s,0.03,0.14,28.22,0.30 



sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqrd prepare

sysbench fileio --threads=4 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqrd-threads-4-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 11203.75
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 43.76
written-MiB/s: 0.00
time: 10.0004s
min: 0.07
avg: 0.36
max: 38.12
95th: 0.94

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 4 | 4KiB | I/O | read | 11203.75 | 0.00 | 0.00 | 43.76 | 0.00 | 10.0004s | 0.07 | 0.36 | 38.12 | 0.94 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,4,4KiB,I/O,read,11203.75,0.00,0.00,43.76,0.00,10.0004s,0.07,0.36,38.12,0.94 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=seqwr prepare

sysbench fileio --threads=4 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=seqwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-seqwr-threads-4-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 1880.59
fsyncs/s: 2404.72
read-MiB/s: 0.00
written-MiB/s: 7.35
time: 10.0036s
min: 0.04
avg: 0.93
max: 915.37
95th: 2.18

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 4 | 4KiB | I/O | write | 0.00 | 1880.59 | 2404.72 | 0.00 | 7.35 | 10.0036s | 0.04 | 0.93 | 915.37 | 2.18 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,4,4KiB,I/O,write,0.00,1880.59,2404.72,0.00,7.35,10.0036s,0.04,0.93,915.37,2.18 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndrd prepare

sysbench fileio --threads=4 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndrd --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndrd-threads-4-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 8220.03
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 32.11
written-MiB/s: 0.00
time: 10.0035s
min: 0.07
avg: 0.48
max: 77.96
95th: 1.39

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 4 | 4KiB | I/O | read | 8220.03 | 0.00 | 0.00 | 32.11 | 0.00 | 10.0035s | 0.07 | 0.48 | 77.96 | 1.39 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,4,4KiB,I/O,read,8220.03,0.00,0.00,32.11,0.00,10.0035s,0.07,0.48,77.96,1.39 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

sysbench fileio prepare
sysbench fileio --file-total-size=2048M --file-test-mode=rndwr prepare

sysbench fileio --threads=4 --file-num=128 --file-total-size=2048M --file-block-size=4096 --file-io-mode=sync --file-extra-flags=direct --file-test-mode=rndwr --time=10 --events=0 run
raw log saved: /home/sysbench/sysbench-fileio-rndwr-threads-4-raw.log

sysbench 1.0.11 (using system LuaJIT 2.1.0-beta3)
threads: 4
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 5878.52
fsyncs/s: 7514.80
read-MiB/s: 0.00
written-MiB/s: 22.96
time: 10.0002s
min: 0.04
avg: 0.30
max: 68.52
95th: 0.80

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.11 | 4 | 4KiB | I/O | write | 0.00 | 5878.52 | 7514.80 | 0.00 | 22.96 | 10.0002s | 0.04 | 0.30 | 68.52 | 0.80 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.11,4,4KiB,I/O,write,0.00,5878.52,7514.80,0.00,22.96,10.0002s,0.04,0.30,68.52,0.80 


sysbench fileio cleanup
sysbench fileio --file-total-size=2048M cleanup

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.11 | 1 | 4KiB | I/O | read | 4045.57 | 0.00 | 0.00 | 15.80 | 0.00 | 10.0003s | 0.08 | 0.25 | 48.10 | 0.49 |
|fileio | 1.0.11 | 1 | 4KiB | I/O | write | 0.00 | 1919.47 | 2446.13 | 0.00 | 7.50 | 10.0002s | 0.03 | 0.23 | 37.70 | 0.46 |
|fileio | 1.0.11 | 4 | 4KiB | I/O | read | 11203.75 | 0.00 | 0.00 | 43.76 | 0.00 | 10.0004s | 0.07 | 0.36 | 38.12 | 0.94 |
|fileio | 1.0.11 | 4 | 4KiB | I/O | write | 0.00 | 1880.59 | 2404.72 | 0.00 | 7.35 | 10.0036s | 0.04 | 0.93 | 915.37 | 2.18 |

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.11 | 1 | 4KiB | I/O | read | 2916.12 | 0.00 | 0.00 | 11.39 | 0.00 | 10.0005s | 0.08 | 0.34 | 41.85 | 0.58 |
|fileio | 1.0.11 | 1 | 4KiB | I/O | write | 0.00 | 3141.23 | 4018.34 | 0.00 | 12.27 | 10.0002s | 0.03 | 0.14 | 28.22 | 0.30 |
|fileio | 1.0.11 | 4 | 4KiB | I/O | read | 8220.03 | 0.00 | 0.00 | 32.11 | 0.00 | 10.0035s | 0.07 | 0.48 | 77.96 | 1.39 |
|fileio | 1.0.11 | 4 | 4KiB | I/O | write | 0.00 | 5878.52 | 7514.80 | 0.00 | 22.96 | 10.0002s | 0.04 | 0.30 | 68.52 | 0.80 |
```

# sysbench HTML report

```bash
./sysbench.sh cpu
./sysbench.sh mem
./sysbench.sh fileio
./sysbench.sh fileio-fsync
./sysbench.sh fileio-fsync-16k
./sysbench.sh mysqloltpnew
./sysbench.sh --export-html $(pwd)
```

![sysbench HTML report Screenshots](/screenshots/sysbench_report_html.png)