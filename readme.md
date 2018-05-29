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

## sysbench mysql read/write OLTP

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


## sysbench mysql read only OLTP

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

## sysbench mysql insert

```
./sysbench.sh mysqlinsert             

setup sbt database & user
mysqladmin create database: sbt

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

sysbench prepare database: sbt
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest2'...Creating table 'sbtest8'...
Creating table 'sbtest4'...
Creating table 'sbtest5'...Creating table 'sbtest6'...
Creating table 'sbtest3'...
Creating table 'sbtest1'...

Creating table 'sbtest7'...

Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest4'
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest3'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.08MB    | 0.00MB     | 0.08MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.13MB    | 0.00MB     | 0.13MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.11MB    | 0.00MB     | 0.11MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.14MB    | 0.00MB     | 0.14MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP new benchmark:
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2080.08 qps: 41667.42 (r/w/o: 29178.98/8320.30/4168.14) lat (ms,95%): 5.00 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2491.42 qps: 49850.34 (r/w/o: 34893.84/9973.67/4982.83) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 2566.96 qps: 51338.11 (r/w/o: 35944.37/10259.82/5133.91) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 2621.98 qps: 52452.52 (r/w/o: 36719.66/10488.90/5243.95) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2670.00 qps: 53396.08 (r/w/o: 37374.05/10682.02/5340.01) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2657.01 qps: 53108.26 (r/w/o: 37169.18/10625.05/5314.03) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2737.06 qps: 54775.19 (r/w/o: 38348.83/10952.24/5474.12) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2756.96 qps: 55135.21 (r/w/o: 38596.44/11024.84/5513.92) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2795.01 qps: 55923.14 (r/w/o: 39140.10/11193.03/5590.01) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2805.96 qps: 56097.19 (r/w/o: 39269.43/11216.84/5610.92) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2773.04 qps: 55444.85 (r/w/o: 38812.59/11085.17/5547.08) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2774.06 qps: 55497.13 (r/w/o: 38852.79/11096.23/5548.11) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2793.93 qps: 55874.66 (r/w/o: 39110.06/11176.73/5587.87) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2749.04 qps: 54965.87 (r/w/o: 38468.61/10999.17/5498.09) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2765.04 qps: 55324.72 (r/w/o: 38734.51/11060.14/5530.07) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2734.94 qps: 54682.75 (r/w/o: 38273.12/10939.75/5469.87) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2742.01 qps: 54834.22 (r/w/o: 38386.16/10964.04/5484.02) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2721.00 qps: 54378.95 (r/w/o: 38053.96/10883.99/5440.99) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2763.98 qps: 55308.58 (r/w/o: 38723.70/11055.92/5528.96) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2746.05 qps: 54960.99 (r/w/o: 38483.69/10985.20/5492.10) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 2730.96 qps: 54582.25 (r/w/o: 38198.48/10922.85/5460.93) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 2744.91 qps: 54935.21 (r/w/o: 38455.75/10988.64/5490.82) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 2815.00 qps: 56290.04 (r/w/o: 39406.03/11254.01/5630.00) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 2772.08 qps: 55448.68 (r/w/o: 38811.18/11093.34/5544.17) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 2807.90 qps: 56147.95 (r/w/o: 39305.56/11226.59/5615.79) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 2791.83 qps: 55841.52 (r/w/o: 39093.56/11164.30/5583.65) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 2823.23 qps: 56431.59 (r/w/o: 39491.21/11293.92/5646.46) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 2880.04 qps: 57612.75 (r/w/o: 40333.52/11519.15/5760.07) lat (ms,95%): 3.62 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 2930.03 qps: 58601.55 (r/w/o: 41019.39/11724.11/5858.06) lat (ms,95%): 3.68 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 2844.70 qps: 56894.98 (r/w/o: 39822.79/11380.80/5691.40) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1146558
        write:                           327588
        other:                           163794
        total:                           1637940
    transactions:                        81897  (2729.36 per sec.)
    queries:                             1637940 (54587.20 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0049s
    total number of events:              81897

Latency (ms):
         min:                                    1.12
         avg:                                    2.93
         max:                                  101.01
         95th percentile:                        4.03
         sum:                               239869.67

Threads fairness:
    events (avg/stddev):           10237.1250/31.38
    execution time (avg/stddev):   29.9837/0.00


sysbench mysql OLTP new summary:
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1146558
write: 327588
other: 163794
total: 1637940
transactions/s: 2729.36
queries/s: 54587.20
time: 30.0049s
min: 1.12
avg: 2.93
max: 101.01
95th: 4.03

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_write.lua | 1.0.14 | 8 | 1146558 | 327588 | 163794 | 1637940 | 2729.36 | 54587.20 | 30.0049s | 1.12 | 2.93 | 101.01 | 4.03 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_read_write.lua,1.0.14,8,1146558,327588,163794,1637940,2729.36,54587.20,30.0049s,1.12,2.93,101.01,4.03 

sysbench mysql cleanup database: sbt
sysbench oltp_read_write.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
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
| oltp_read_write.lua | 1.0.14 | 8 | 1146558 | 327588 | 163794 | 1637940 | 2729.36 | 54587.20 | 30.0049s | 1.12 | 2.93 | 101.01 | 4.03 |


## sysbench mysql OLTP new read only

```
.sysbench.sh mysqlreadonly-new

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest2'...
Creating table 'sbtest1'...
Creating table 'sbtest5'...Creating table 'sbtest8'...Creating table 'sbtest6'...
Creating table 'sbtest4'...


Creating table 'sbtest7'...
Creating table 'sbtest3'...
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest2'
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest1'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.14MB    | 0.00MB     | 0.14MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.08MB    | 0.00MB     | 0.08MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.06MB    | 0.00MB     | 0.06MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP read only new benchmark:
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2959.89 qps: 47454.07 (r/w/o: 41526.31/0.00/5927.76) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2758.53 qps: 44129.43 (r/w/o: 38612.38/0.00/5517.05) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 3413.04 qps: 54594.68 (r/w/o: 47769.59/0.00/6825.08) lat (ms,95%): 3.75 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 3461.96 qps: 55377.29 (r/w/o: 48452.38/0.00/6924.91) lat (ms,95%): 3.19 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 3243.97 qps: 51930.52 (r/w/o: 45442.58/0.00/6487.94) lat (ms,95%): 3.49 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 3077.04 qps: 49190.71 (r/w/o: 43036.63/0.00/6154.09) lat (ms,95%): 3.62 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2912.96 qps: 46627.35 (r/w/o: 40801.43/0.00/5825.92) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2832.99 qps: 45354.88 (r/w/o: 39688.89/0.00/5665.99) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2771.03 qps: 44334.52 (r/w/o: 38792.45/0.00/5542.06) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2758.01 qps: 44124.13 (r/w/o: 38608.11/0.00/5516.02) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2728.96 qps: 43659.35 (r/w/o: 38200.43/0.00/5458.92) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2710.01 qps: 43350.19 (r/w/o: 37931.16/0.00/5419.02) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2694.03 qps: 43110.45 (r/w/o: 37722.39/0.00/5388.06) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2706.97 qps: 43306.55 (r/w/o: 37892.61/0.00/5413.94) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2653.01 qps: 42447.10 (r/w/o: 37141.09/0.00/5306.01) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 2648.02 qps: 42365.36 (r/w/o: 37069.31/0.00/5296.04) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 2633.02 qps: 42122.25 (r/w/o: 36856.22/0.00/5266.03) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 2586.96 qps: 41382.36 (r/w/o: 36208.44/0.00/5173.92) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 2590.00 qps: 41458.06 (r/w/o: 36278.05/0.00/5180.01) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 2577.97 qps: 41240.50 (r/w/o: 36084.57/0.00/5155.94) lat (ms,95%): 4.25 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 2548.03 qps: 40779.52 (r/w/o: 35683.46/0.00/5096.07) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 2553.01 qps: 40854.23 (r/w/o: 35748.20/0.00/5106.03) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 2532.98 qps: 40546.62 (r/w/o: 35480.67/0.00/5065.95) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 2525.03 qps: 40366.47 (r/w/o: 35316.41/0.00/5050.06) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 2524.00 qps: 40386.94 (r/w/o: 35339.94/0.00/5046.99) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 2499.03 qps: 39967.50 (r/w/o: 34968.44/0.00/4999.06) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 2498.97 qps: 40005.46 (r/w/o: 35007.53/0.00/4997.93) lat (ms,95%): 4.49 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 2508.98 qps: 40144.68 (r/w/o: 35126.72/0.00/5017.96) lat (ms,95%): 4.33 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 2479.04 qps: 39648.56 (r/w/o: 34691.49/0.00/4957.07) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 2505.78 qps: 40108.41 (r/w/o: 35095.86/0.00/5012.55) lat (ms,95%): 4.41 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1146670
        write:                           0
        other:                           163810
        total:                           1310480
    transactions:                        81905  (2729.71 per sec.)
    queries:                             1310480 (43675.38 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0039s
    total number of events:              81905

Latency (ms):
         min:                                    0.55
         avg:                                    2.93
         max:                                   11.48
         95th percentile:                        4.18
         sum:                               239874.74

Threads fairness:
    events (avg/stddev):           10238.1250/27.92
    execution time (avg/stddev):   29.9843/0.00


sysbench mysql OLTP read only new summary:
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1146670
write: 0
other: 163810
total: 1310480
transactions/s: 2729.71
queries/s: 43675.38
time: 30.0039s
min: 0.55
avg: 2.93
max: 11.48
95th: 4.18

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_read_only.lua | 1.0.14 | 8 | 1146670 | 0 | 163810 | 1310480 | 2729.71 | 43675.38 | 30.0039s | 0.55 | 2.93 | 11.48 | 4.18 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_read_only.lua,1.0.14,8,1146670,0,163810,1310480,2729.71,43675.38,30.0039s,0.55,2.93,11.48,4.18 

sysbench mysql cleanup database: sbt
sysbench oltp_read_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
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

## sysbench mysql OLTP new write only

```
./sysbench.sh mysqlwriteonly-new                             

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest5'...Creating table 'sbtest7'...Creating table 'sbtest2'...Creating table 'sbtest3'...



Creating table 'sbtest4'...
Creating table 'sbtest1'...
Creating table 'sbtest6'...
Creating table 'sbtest8'...
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest6'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest4'
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest7'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest1'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.11MB    | 0.00MB     | 0.11MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150000 Rows    | InnoDB         | 0.11MB    | 0.00MB     | 0.11MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.11MB    | 0.00MB     | 0.11MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.13MB    | 0.00MB     | 0.13MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.06MB    | 0.00MB     | 0.06MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.14MB    | 0.00MB     | 0.14MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP write only new benchmark:
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 6692.83 qps: 40185.96 (r/w/o: 0.00/26792.30/13393.65) lat (ms,95%): 1.76 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 10401.88 qps: 62405.27 (r/w/o: 0.00/41601.51/20803.76) lat (ms,95%): 1.23 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 13996.60 qps: 83996.61 (r/w/o: 0.00/56003.40/27993.20) lat (ms,95%): 1.01 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 13840.02 qps: 83015.13 (r/w/o: 0.00/55336.09/27679.04) lat (ms,95%): 0.94 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 12799.90 qps: 76797.40 (r/w/o: 0.00/51197.60/25599.80) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 12309.56 qps: 73871.37 (r/w/o: 0.00/49251.24/24620.12) lat (ms,95%): 0.92 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 13361.24 qps: 80155.42 (r/w/o: 0.00/53432.95/26722.47) lat (ms,95%): 0.89 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 13350.09 qps: 80106.55 (r/w/o: 0.00/53407.37/26699.18) lat (ms,95%): 0.89 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 13537.88 qps: 81226.31 (r/w/o: 0.00/54149.54/27076.77) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 13913.23 qps: 83487.37 (r/w/o: 0.00/55660.91/27826.46) lat (ms,95%): 0.84 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 14275.21 qps: 85663.23 (r/w/o: 0.00/57112.82/28550.41) lat (ms,95%): 0.84 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 16035.54 qps: 96190.21 (r/w/o: 0.00/64121.14/32069.07) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 12973.07 qps: 77848.45 (r/w/o: 0.00/51901.30/25947.15) lat (ms,95%): 0.89 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 14381.53 qps: 86297.16 (r/w/o: 0.00/57533.11/28764.05) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 13734.29 qps: 82390.72 (r/w/o: 0.00/54923.15/27467.58) lat (ms,95%): 0.89 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 14402.99 qps: 86413.95 (r/w/o: 0.00/57608.97/28804.98) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 14065.16 qps: 84406.97 (r/w/o: 0.00/56274.65/28132.32) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 14174.09 qps: 85029.55 (r/w/o: 0.00/56681.37/28348.18) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 14124.09 qps: 84748.54 (r/w/o: 0.00/56500.36/28248.18) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 14652.79 qps: 87925.75 (r/w/o: 0.00/58620.17/29305.58) lat (ms,95%): 0.86 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 14468.01 qps: 86804.08 (r/w/o: 0.00/57868.05/28936.03) lat (ms,95%): 0.80 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 14787.02 qps: 88720.12 (r/w/o: 0.00/59146.08/29574.04) lat (ms,95%): 0.83 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 13106.77 qps: 78640.60 (r/w/o: 0.00/52427.07/26213.53) lat (ms,95%): 0.94 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 13034.57 qps: 78207.41 (r/w/o: 0.00/52140.27/26067.14) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 13755.04 qps: 82523.22 (r/w/o: 0.00/55012.14/27511.07) lat (ms,95%): 0.87 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 14762.20 qps: 88582.18 (r/w/o: 0.00/59057.78/29524.39) lat (ms,95%): 0.81 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 15042.52 qps: 90260.14 (r/w/o: 0.00/60175.10/30085.05) lat (ms,95%): 0.78 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 13855.86 qps: 83122.14 (r/w/o: 0.00/55410.43/27711.71) lat (ms,95%): 0.90 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 15243.79 qps: 91465.73 (r/w/o: 0.00/60978.15/30487.58) lat (ms,95%): 0.75 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 14933.97 qps: 89613.80 (r/w/o: 0.00/59744.87/29868.93) lat (ms,95%): 0.81 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           1640116
        other:                           820058
        total:                           2460174
    transactions:                        410029 (13665.96 per sec.)
    queries:                             2460174 (81995.74 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0026s
    total number of events:              410029

Latency (ms):
         min:                                    0.15
         avg:                                    0.58
         max:                                  233.35
         95th percentile:                        0.89
         sum:                               239503.71

Threads fairness:
    events (avg/stddev):           51253.6250/405.08
    execution time (avg/stddev):   29.9380/0.00


sysbench mysql OLTP write only new summary:
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 0
write: 1640116
other: 820058
total: 2460174
transactions/s: 13665.96
queries/s: 81995.74
time: 30.0026s
min: 0.15
avg: 0.58
max: 233.35
95th: 0.89

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_write_only.lua | 1.0.14 | 8 | 0 | 1640116 | 820058 | 2460174 | 13665.96 | 81995.74 | 30.0026s | 0.15 | 0.58 | 233.35 | 0.89 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_write_only.lua,1.0.14,8,0,1640116,820058,2460174,13665.96,81995.74,30.0026s,0.15,0.58,233.35,0.89 

sysbench mysql cleanup database: sbt
sysbench oltp_write_only.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
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
| oltp_write_only.lua | 1.0.14 | 8 | 0 | 1640116 | 820058 | 2460174 | 13665.96 | 81995.74 | 30.0026s | 0.15 | 0.58 | 233.35 | 0.89 |

## sysbench mysql OLTP new point select

```
./sysbench.sh mysqlpointselect-new                           

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql prepare
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest3'...
Creating table 'sbtest5'...
Creating table 'sbtest8'...
Creating table 'sbtest1'...
Creating table 'sbtest7'...
Creating table 'sbtest2'...
Creating table 'sbtest6'...
Creating table 'sbtest4'...
Inserting 150000 records into 'sbtest1'
Inserting 150000 records into 'sbtest8'
Inserting 150000 records into 'sbtest3'
Inserting 150000 records into 'sbtest5'
Inserting 150000 records into 'sbtest7'
Inserting 150000 records into 'sbtest4'
Inserting 150000 records into 'sbtest2'
Inserting 150000 records into 'sbtest6'
Creating a secondary index on 'sbtest1'...
Creating a secondary index on 'sbtest8'...
Creating a secondary index on 'sbtest3'...
Creating a secondary index on 'sbtest5'...
Creating a secondary index on 'sbtest6'...
Creating a secondary index on 'sbtest2'...
Creating a secondary index on 'sbtest4'...
Creating a secondary index on 'sbtest7'...

+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| Table Name  | Number of Rows | Storage Engine | Data Size | Index Size | Total  | ROW_FORMAT | TABLE_COLLATION |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+
| sbt.sbtest1 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest2 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest3 | 150001 Rows    | InnoDB         | 0.17MB    | 0.00MB     | 0.17MB | Compact    | utf8_general_ci |
| sbt.sbtest4 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest5 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest6 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest7 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
| sbt.sbtest8 | 150000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB | Compact    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+--------+------------+-----------------+

sysbench mysql OLTP POINT SELECT new benchmark:
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 66300.44 qps: 66300.44 (r/w/o: 66300.44/0.00/0.00) lat (ms,95%): 0.28 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 69689.54 qps: 69689.54 (r/w/o: 69689.54/0.00/0.00) lat (ms,95%): 0.30 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 65390.06 qps: 65390.06 (r/w/o: 65390.06/0.00/0.00) lat (ms,95%): 0.32 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 66191.20 qps: 66191.20 (r/w/o: 66191.20/0.00/0.00) lat (ms,95%): 0.31 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 64178.35 qps: 64178.35 (r/w/o: 64178.35/0.00/0.00) lat (ms,95%): 0.32 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 62698.79 qps: 62698.79 (r/w/o: 62698.79/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 61742.38 qps: 61742.38 (r/w/o: 61742.38/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 61914.50 qps: 61914.50 (r/w/o: 61914.50/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 63273.36 qps: 63273.36 (r/w/o: 63273.36/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 64394.30 qps: 64394.30 (r/w/o: 64394.30/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 63719.67 qps: 63719.67 (r/w/o: 63719.67/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 64046.71 qps: 64046.71 (r/w/o: 64046.71/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 63060.16 qps: 63060.16 (r/w/o: 63060.16/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 62765.60 qps: 62765.60 (r/w/o: 62765.60/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 62595.66 qps: 62595.66 (r/w/o: 62595.66/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 16s ] thds: 8 tps: 62724.72 qps: 62724.72 (r/w/o: 62724.72/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 17s ] thds: 8 tps: 62561.09 qps: 62561.09 (r/w/o: 62561.09/0.00/0.00) lat (ms,95%): 0.33 err/s: 0.00 reconn/s: 0.00
[ 18s ] thds: 8 tps: 62885.06 qps: 62885.06 (r/w/o: 62885.06/0.00/0.00) lat (ms,95%): 0.33 err/s: 0.00 reconn/s: 0.00
[ 19s ] thds: 8 tps: 63289.75 qps: 63289.75 (r/w/o: 63289.75/0.00/0.00) lat (ms,95%): 0.33 err/s: 0.00 reconn/s: 0.00
[ 20s ] thds: 8 tps: 60850.00 qps: 60850.00 (r/w/o: 60850.00/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 21s ] thds: 8 tps: 61268.89 qps: 61268.89 (r/w/o: 61268.89/0.00/0.00) lat (ms,95%): 0.34 err/s: 0.00 reconn/s: 0.00
[ 22s ] thds: 8 tps: 60798.86 qps: 60798.86 (r/w/o: 60798.86/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 23s ] thds: 8 tps: 61173.54 qps: 61173.54 (r/w/o: 61173.54/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 24s ] thds: 8 tps: 61184.70 qps: 61184.70 (r/w/o: 61184.70/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 25s ] thds: 8 tps: 60923.96 qps: 60923.96 (r/w/o: 60923.96/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 26s ] thds: 8 tps: 60620.91 qps: 60620.91 (r/w/o: 60620.91/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 27s ] thds: 8 tps: 60753.54 qps: 60753.54 (r/w/o: 60753.54/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 28s ] thds: 8 tps: 60570.85 qps: 60570.85 (r/w/o: 60570.85/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 29s ] thds: 8 tps: 61266.00 qps: 61266.00 (r/w/o: 61266.00/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
[ 30s ] thds: 8 tps: 61563.86 qps: 61563.86 (r/w/o: 61563.86/0.00/0.00) lat (ms,95%): 0.35 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            1884489
        write:                           0
        other:                           0
        total:                           1884489
    transactions:                        1884489 (62809.90 per sec.)
    queries:                             1884489 (62809.90 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          30.0020s
    total number of events:              1884489

Latency (ms):
         min:                                    0.01
         avg:                                    0.13
         max:                                    7.90
         95th percentile:                        0.34
         sum:                               239248.31

Threads fairness:
    events (avg/stddev):           235561.1250/451.27
    execution time (avg/stddev):   29.9060/0.00


sysbench mysql OLTP POINT SELECT new summary:
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 1884489
write: 0
other: 0
total: 1884489
transactions/s: 62809.90
queries/s: 62809.90
time: 30.0020s
min: 0.01
avg: 0.13
max: 7.90
95th: 0.34

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp_point_select.lua | 1.0.14 | 8 | 1884489 | 0 | 0 | 1884489 | 62809.90 | 62809.90 | 30.0020s | 0.01 | 0.13 | 7.90 | 0.34 |

sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th 
oltp_point_select.lua,1.0.14,8,1884489,0,0,1884489,62809.90,62809.90,30.0020s,0.01,0.13,7.90,0.34 

sysbench mysql cleanup database: sbt
sysbench oltp_point_select.lua --mysql-host=localhost --mysql-port=3306 --mysql-socket=/var/lib/mysql/mysql.sock --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --mysql-storage-engine=InnoDB --time=30 --threads=8 --report-interval=1 --table-size=150000 --tables=8 --db-driver=mysql cleanup
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
| oltp_point_select.lua | 1.0.14 | 8 | 1884489 | 0 | 0 | 1884489 | 62809.90 | 62809.90 | 30.0020s | 0.01 | 0.13 | 7.90 | 0.34 |