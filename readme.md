# sysbench contents

* [sysbench.sh tool](#sysbenchsh-tool)
* [sysbench.sh install](#sysbench-install)
* [sysbench.sh update](#sysbench-update)
* [sysbench.sh usage](#sysbench-usage)
* [sysbench cpu benchmark](#sysbench-cpu)
* [sysbench memory benchmark](#sysbench-memory)
* [sysbench fileio benchmark](#sysbench-fileio)
* [sysbench mysql read/write benchmark](#sysbench-mysql-readwrite)
* [sysbench mysql read only benchmark](#sysbench-mysql-read-only)

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
total 192K
drwxr-xr-x 2 root root 4.0K May 28 06:22 fileio
drwxr-xr-x 2 root root 4.0K May 24 16:47 mysql
-rw-r--r-- 1 root root  199 May 28 06:18 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  182 May 28 06:18 sysbench-cpu-threads-1-markdown.log
-rw-r--r-- 1 root root  201 May 28 06:18 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  184 May 28 06:18 sysbench-cpu-threads-8-markdown.log
-rw-r--r-- 1 root root  504 May 28 06:20 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  390 May 28 06:20 sysbench-fileio-rndrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:20 sysbench-fileio-rndrd-threads-1-raw.log
-rw-r--r-- 1 root root  506 May 28 06:22 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  392 May 28 06:22 sysbench-fileio-rndrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:22 sysbench-fileio-rndrd-threads-8-raw.log
-rw-r--r-- 1 root root  510 May 28 06:21 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  396 May 28 06:21 sysbench-fileio-rndwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:21 sysbench-fileio-rndwr-threads-1-raw.log
-rw-r--r-- 1 root root  510 May 28 06:22 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  396 May 28 06:22 sysbench-fileio-rndwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:22 sysbench-fileio-rndwr-threads-8-raw.log
-rw-r--r-- 1 root root  459 May 28 06:19 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  396 May 28 06:19 sysbench-fileio-seqrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.2K May 28 06:19 sysbench-fileio-seqrd-threads-1-raw.log
-rw-r--r-- 1 root root  459 May 28 06:21 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  396 May 28 06:21 sysbench-fileio-seqrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.2K May 28 06:21 sysbench-fileio-seqrd-threads-8-raw.log
-rw-r--r-- 1 root root  474 May 28 06:20 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  400 May 28 06:20 sysbench-fileio-seqwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:20 sysbench-fileio-seqwr-threads-1-raw.log
-rw-r--r-- 1 root root  474 May 28 06:21 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  400 May 28 06:21 sysbench-fileio-seqwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 28 06:21 sysbench-fileio-seqwr-threads-8-raw.log
-rw-r--r-- 1 root root  376 May 28 06:18 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  322 May 28 06:18 sysbench-mem-threads-1-markdown.log
-rw-r--r-- 1 root root  378 May 28 06:18 sysbench-mem-threads-8.log
-rw-r--r-- 1 root root  323 May 28 06:18 sysbench-mem-threads-8-markdown.log
-rw-r--r-- 1 root root  429 May 28 06:31 sysbench-mysql-cleanup-threads-8.log
-rw-r--r-- 1 root root  429 May 28 06:44 sysbench-mysql-cleanup-threads-8-readonly.log
-rw-r--r-- 1 root root  761 May 28 06:30 sysbench-mysql-prepare-threads-8.log
-rw-r--r-- 1 root root  761 May 28 06:44 sysbench-mysql-prepare-threads-8-readonly.log
-rw-r--r-- 1 root root  480 May 28 06:31 sysbench-mysql-run-summary-threads-8-corrected.log
-rw-r--r-- 1 root root  510 May 28 06:44 sysbench-mysql-run-summary-threads-8-corrected-readonly.log
-rw-r--r-- 1 root root  512 May 28 06:31 sysbench-mysql-run-summary-threads-8.log
-rw-r--r-- 1 root root  344 May 28 06:31 sysbench-mysql-run-summary-threads-8-markdown.log
-rw-r--r-- 1 root root  335 May 28 06:44 sysbench-mysql-run-summary-threads-8-markdown-readonly.log
-rw-r--r-- 1 root root  542 May 28 06:44 sysbench-mysql-run-summary-threads-8-readonly.log
-rw-r--r-- 1 root root 4.0K May 28 06:31 sysbench-mysql-run-threads-8.log
-rw-r--r-- 1 root root 3.9K May 28 06:44 sysbench-mysql-run-threads-8-readonly.log
-rw-r--r-- 1 root root  928 May 28 06:31 sysbench-mysql-table-list.log
-rw-r--r-- 1 root root  928 May 28 06:44 sysbench-mysql-table-list-readonly.log
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
./sysbench.sh {install|update|cpu|mem|file|mysql|mysqlro}
```

## sysbench cpu

sysbench cpu tests test both single thread and max cpu core/thread count for comparison

```
./sysbench.sh cpu

sysbench cpu --cpu-max-prime=20000 --threads=1 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
prime: 20000
events/s: 525.58
time: 10.0011s
min: 1.90
avg: 1.90
max: 2.35
95th: 1.89

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.58 | 10.0011s | 1.90 | 1.90 | 2.35 | 1.89 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.14,1,525.58,10.0011s,1.90,1.90,2.35,1.89 

sysbench cpu --cpu-max-prime=20000 --threads=8 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
prime: 20000
events/s: 3232.75
time: 10.0018s
min: 1.90
avg: 2.47
max: 38.64
95th: 2.48

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 8 | 3232.75 | 10.0018s | 1.90 | 2.47 | 38.64 | 2.48 |

sysbench,threads,events/s,time,min,avg,max,95th 
1.0.14,8,3232.75,10.0018s,1.90,2.47,38.64,2.48 
```

Markdown results table

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.58 | 10.0011s | 1.90 | 1.90 | 2.35 | 1.89 |
| 1.0.14 | 8 | 3232.75 | 10.0018s | 1.90 | 2.47 | 38.64 | 2.48 |

## sysbench memory

sysbench memory tests test both single thread and max cpu core/thread count for comparison

```
./sysbench.sh mem

sysbench memory --threads=1 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (8189451.03 per second)
transferred (7997.51 MiB/sec)
time: 0.1268s
min: 0.00
avg: 0.00
max: 0.00
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7997.51 | 0.1268s | 0.00 | 0.00 | 0.00 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.14,1,1KiB,1024MiB,read,1048576,7997.51,0.1268s,0.00,0.00,0.00,0.00 

sysbench memory --threads=8 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (27524346.98 per second)
transferred (26879.25 MiB/sec)
time: 0.0369s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 26879.25 | 0.0369s | 0.00 | 0.00 | 0.01 | 0.00 |

sysbench,sysbench,threads,block-size,total-size,operation,total-ops,transferred,time,min,avg,max,95th 
memory,1.0.14,8,1KiB,1024MiB,read,1048576,26879.25,0.0369s,0.00,0.00,0.01,0.00 
```

Markdown results table

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7997.51 | 0.1268s | 0.00 | 0.00 | 0.00 | 0.00 |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 26879.25 | 0.0369s | 0.00 | 0.00 | 0.01 | 0.00 |

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

## sysbench mysql read/write

```
./sysbench.sh mysql

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 100000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 100000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 100000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 100000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 98712 Rows     | InnoDB         | 21.55MB   | 1.52MB     | 23.06MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest4 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql benchmark:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2253.91 qps: 45164.03 (r/w/o: 31630.60/9017.63/4515.80) lat (ms,95%): 4.82 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2471.39 qps: 49435.81 (r/w/o: 34605.46/9887.56/4942.78) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 2572.99 qps: 51453.87 (r/w/o: 36019.91/10288.97/5144.99) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 2571.99 qps: 51432.76 (r/w/o: 36000.83/10286.95/5144.98) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2587.99 qps: 51759.81 (r/w/o: 36231.87/10351.96/5175.98) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2590.95 qps: 51830.92 (r/w/o: 36285.24/10363.78/5181.89) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2416.05 qps: 48326.08 (r/w/o: 33829.76/9664.22/4832.11) lat (ms,95%): 5.57 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2627.95 qps: 52570.01 (r/w/o: 36794.31/10519.80/5255.90) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2657.02 qps: 53124.33 (r/w/o: 37183.23/10627.07/5314.03) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2673.04 qps: 53443.89 (r/w/o: 37412.62/10685.18/5346.09) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2612.06 qps: 52264.13 (r/w/o: 36591.79/10448.23/5224.11) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2680.89 qps: 53591.83 (r/w/o: 37506.48/10723.57/5361.78) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2585.10 qps: 51733.95 (r/w/o: 36216.37/10347.39/5170.19) lat (ms,95%): 4.65 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2682.96 qps: 53635.16 (r/w/o: 37544.41/10724.83/5365.92) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2626.96 qps: 52549.10 (r/w/o: 36784.37/10511.82/5252.91) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2629.96 qps: 52608.26 (r/w/o: 36827.48/10519.85/5260.93) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2733.11 qps: 54655.18 (r/w/o: 38258.53/10930.44/5466.22) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2657.04 qps: 53125.75 (r/w/o: 37185.52/10626.15/5314.07) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2712.93 qps: 54253.56 (r/w/o: 37975.99/10851.71/5425.86) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2758.85 qps: 55204.95 (r/w/o: 38650.87/11036.39/5517.70) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            729596
        write:                           208456
        other:                           104228
        total:                           1042280
    transactions:                        52114  (2605.23 per sec.)
    queries:                             1042280 (52104.68 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          20.0025s
    total number of events:              52114

Latency (ms):
         min:                                    1.18
         avg:                                    3.07
         max:                                   73.40
         95th percentile:                        4.33
         sum:                               159924.43

Threads fairness:
    events (avg/stddev):           6514.2500/29.24
    execution time (avg/stddev):   19.9906/0.00


sysbench mysql summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 729596
write: 208456
other: 104228
total: 1042280
transactions/s: 2605.23
queries/s: 52104.68
time: 20.0025s
min: 1.18
avg: 3.07
max: 73.40
95th: 4.33

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 729596 | 208456 | 104228 | 1042280 | 2605.23 | 52104.68 | 20.0025s | 1.18 | 3.07 | 73.40 | 4.33 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp.lua,1.0.14,8,729596,208456,104228,1042280,2605.23,52104.68,20.0025s,1.18,3.07,73.40,4.33 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 729596 | 208456 | 104228 | 1042280 | 2605.23 | 52104.68 | 20.0025s | 1.18 | 3.07 | 73.40 | 4.33 |

## sysbench mysql read only

```
./sysbench.sh mysqlro

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Creating table 'sbtest1'...
Inserting 100000 records into 'sbtest1'
Creating secondary indexes on 'sbtest1'...
Creating table 'sbtest2'...
Inserting 100000 records into 'sbtest2'
Creating secondary indexes on 'sbtest2'...
Creating table 'sbtest3'...
Inserting 100000 records into 'sbtest3'
Creating secondary indexes on 'sbtest3'...
Creating table 'sbtest4'...
Inserting 100000 records into 'sbtest4'
Creating secondary indexes on 'sbtest4'...

+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total   | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+
| sbt.sbtest1 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest2 | 98712 Rows     | InnoDB         | 21.55MB   | 1.52MB     | 23.06MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
| sbt.sbtest4 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql read only benchmark:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 3691.59 qps: 51727.16 (r/w/o: 51727.16/0.00/0.00) lat (ms,95%): 3.07 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 4556.74 qps: 63828.29 (r/w/o: 63828.29/0.00/0.00) lat (ms,95%): 2.66 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 4998.28 qps: 69962.91 (r/w/o: 69962.91/0.00/0.00) lat (ms,95%): 2.39 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 4576.08 qps: 64056.11 (r/w/o: 64056.11/0.00/0.00) lat (ms,95%): 2.57 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 4244.00 qps: 59408.01 (r/w/o: 59408.01/0.00/0.00) lat (ms,95%): 2.76 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 4019.02 qps: 56263.32 (r/w/o: 56263.32/0.00/0.00) lat (ms,95%): 2.97 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 3916.96 qps: 54861.41 (r/w/o: 54861.41/0.00/0.00) lat (ms,95%): 3.07 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 3826.00 qps: 53566.99 (r/w/o: 53566.99/0.00/0.00) lat (ms,95%): 3.13 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 3733.01 qps: 52250.11 (r/w/o: 52250.11/0.00/0.00) lat (ms,95%): 3.13 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 3692.02 qps: 51694.24 (r/w/o: 51694.24/0.00/0.00) lat (ms,95%): 3.25 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 3642.95 qps: 51007.33 (r/w/o: 51007.33/0.00/0.00) lat (ms,95%): 3.25 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 3608.05 qps: 50479.73 (r/w/o: 50479.73/0.00/0.00) lat (ms,95%): 3.30 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 3578.04 qps: 50126.56 (r/w/o: 50126.56/0.00/0.00) lat (ms,95%): 3.30 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 3515.95 qps: 49205.30 (r/w/o: 49205.30/0.00/0.00) lat (ms,95%): 3.36 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 3515.02 qps: 49219.30 (r/w/o: 49219.30/0.00/0.00) lat (ms,95%): 3.43 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 3439.98 qps: 48164.70 (r/w/o: 48164.70/0.00/0.00) lat (ms,95%): 3.43 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 3468.98 qps: 48533.70 (r/w/o: 48533.70/0.00/0.00) lat (ms,95%): 3.49 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 3424.02 qps: 47951.35 (r/w/o: 47951.35/0.00/0.00) lat (ms,95%): 3.49 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 3455.00 qps: 48381.02 (r/w/o: 48381.02/0.00/0.00) lat (ms,95%): 3.49 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 3394.67 qps: 47530.33 (r/w/o: 47530.33/0.00/0.00) lat (ms,95%): 3.49 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1068312
        write:                           0
        other:                           0
        total:                           1068312
    transactions:                        76308  (3814.85 per sec.)
    queries:                             1068312 (53407.94 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          20.0018s
    total number of events:              76308

Latency (ms):
         min:                                    0.40
         avg:                                    2.10
         max:                                   11.07
         95th percentile:                        3.19
         sum:                               159907.89

Threads fairness:
    events (avg/stddev):           9538.5000/18.63
    execution time (avg/stddev):   19.9885/0.00


sysbench mysql read only summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1068312
write: 0
other: 0
total: 1068312
transactions/s: 3814.85
queries/s: 53407.94
time: 20.0018s
min: 0.40
avg: 2.10
max: 11.07
95th: 3.19

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1068312 | 0 | 0 | 1068312 | 3814.85 | 53407.94 | 20.0018s | 0.40 | 2.10 | 11.07 | 3.19 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp.lua,1.0.14,8,1068312,0,0,1068312,3814.85,53407.94,20.0018s,0.40,2.10,11.07,3.19 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-table-engine=InnoDB --time=20 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 1068312 | 0 | 0 | 1068312 | 3814.85 | 53407.94 | 20.0018s | 0.40 | 2.10 | 11.07 | 3.19 |