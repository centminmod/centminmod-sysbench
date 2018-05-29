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


## sysbench mysql read only

```
./sysbench.sh mysqlro                 

setup sbt database & user
mysqladmin create database: sbt

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