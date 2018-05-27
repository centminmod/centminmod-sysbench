# sysbench contents

* [sysbench.sh tool](https://github.com/centminmod/centminmod-sysbench#sysbenchsh-tool)
* [sysbench.sh install](https://github.com/centminmod/centminmod-sysbench#sysbench-install)
* [sysbench.sh update](https://github.com/centminmod/centminmod-sysbench#sysbench-update)
* [sysbench.sh usage](https://github.com/centminmod/centminmod-sysbench#sysbench-usage)
* [sysbench cpu benchmark](https://github.com/centminmod/centminmod-sysbench#sysbench-cpu)
* [sysbench memory benchmark](https://github.com/centminmod/centminmod-sysbench#sysbench-memory)
* [sysbench fileio benchmark](https://github.com/centminmod/centminmod-sysbench#sysbench-fileio)
* [sysbench mysql benchmark](https://github.com/centminmod/centminmod-sysbench#sysbench-mysql)

# sysbench.sh tool

`sysbench.sh` benchmark tool utilising [sysbench](https://github.com/akopytov/sysbench). The `sysbench.sh` script is written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing. Results are displayed in 3 formats, standard, github markdown and CSV comma separated.

```
sysbench --version
sysbench 1.0.14
```

each `sysbench.sh` test option saves results into temporary log file in `/home/sysbench/` directory which gets overwritten after each script run.

```
ls -lh /home/sysbench/
total 164K
drwxr-xr-x 2 root root 4.0K May 25 04:35 fileio
drwxr-xr-x 2 root root 4.0K May 24 16:47 mysql
-rw-r--r-- 1 root root  199 May 25 04:51 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  182 May 25 04:51 sysbench-cpu-threads-1-markdown.log
-rw-r--r-- 1 root root  201 May 25 04:51 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  184 May 25 04:51 sysbench-cpu-threads-8-markdown.log
-rw-r--r-- 1 root root  467 May 25 04:33 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  394 May 25 04:33 sysbench-fileio-rndrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:33 sysbench-fileio-rndrd-threads-1-raw.log
-rw-r--r-- 1 root root  469 May 25 04:35 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  396 May 25 04:35 sysbench-fileio-rndrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:35 sysbench-fileio-rndrd-threads-8-raw.log
-rw-r--r-- 1 root root  469 May 25 04:33 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  396 May 25 04:33 sysbench-fileio-rndwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:33 sysbench-fileio-rndwr-threads-1-raw.log
-rw-r--r-- 1 root root  470 May 25 04:35 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  397 May 25 04:35 sysbench-fileio-rndwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:35 sysbench-fileio-rndwr-threads-8-raw.log
-rw-r--r-- 1 root root  421 May 25 04:32 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  399 May 25 04:32 sysbench-fileio-seqrd-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:32 sysbench-fileio-seqrd-threads-1-raw.log
-rw-r--r-- 1 root root  423 May 25 04:34 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  401 May 25 04:34 sysbench-fileio-seqrd-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:34 sysbench-fileio-seqrd-threads-8-raw.log
-rw-r--r-- 1 root root  433 May 25 04:33 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  400 May 25 04:33 sysbench-fileio-seqwr-threads-1-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:33 sysbench-fileio-seqwr-threads-1-raw.log
-rw-r--r-- 1 root root  434 May 25 04:34 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  401 May 25 04:34 sysbench-fileio-seqwr-threads-8-markdown.log
-rw-r--r-- 1 root root 1.3K May 25 04:34 sysbench-fileio-seqwr-threads-8-raw.log
-rw-r--r-- 1 root root  376 May 25 04:51 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  322 May 25 04:51 sysbench-mem-threads-1-markdown.log
-rw-r--r-- 1 root root  379 May 25 04:51 sysbench-mem-threads-8.log
-rw-r--r-- 1 root root  324 May 25 04:51 sysbench-mem-threads-8-markdown.log
-rw-r--r-- 1 root root  401 May 25 04:52 sysbench-mysql-cleanup-threads-8.log
-rw-r--r-- 1 root root  733 May 25 04:51 sysbench-mysql-prepare-threads-8.log
-rw-r--r-- 1 root root  446 May 25 04:52 sysbench-mysql-run-summary-threads-8-corrected.log
-rw-r--r-- 1 root root  481 May 25 04:52 sysbench-mysql-run-summary-threads-8.log
-rw-r--r-- 1 root root  338 May 25 04:52 sysbench-mysql-run-summary-threads-8-markdown.log
-rw-r--r-- 1 root root 3.3K May 25 04:52 sysbench-mysql-run-threads-8.log
-rw-r--r-- 1 root root  928 May 25 04:51 sysbench-mysql-table-list.log
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
Usage:
./sysbench.sh {install|update|cpu|mem|file|mysql}
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

## sysbench mysql

```
./sysbench.sh mysql                   

setup sbt database & user
mysqladmin create database: sbt

sysbench prepare database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql prepare
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
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 8
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 8 tps: 2379.78 qps: 47704.52 (r/w/o: 33412.84/9524.13/4767.56) lat (ms,95%): 4.74 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 8 tps: 2580.37 qps: 51596.35 (r/w/o: 36119.15/10316.47/5160.74) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 8 tps: 2699.00 qps: 53967.97 (r/w/o: 37772.98/10796.99/5398.00) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 8 tps: 2694.05 qps: 53904.00 (r/w/o: 37733.70/10782.20/5388.10) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 8 tps: 2795.99 qps: 55899.87 (r/w/o: 39128.91/11178.97/5591.99) lat (ms,95%): 3.82 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 8 tps: 2786.94 qps: 55723.71 (r/w/o: 39000.10/11149.74/5573.87) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 8 tps: 2746.04 qps: 54918.76 (r/w/o: 38441.53/10985.15/5492.08) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 8 tps: 2787.99 qps: 55774.88 (r/w/o: 39050.92/11147.98/5575.99) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 8 tps: 2812.93 qps: 56261.51 (r/w/o: 39381.95/11253.70/5625.85) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 8 tps: 2817.05 qps: 56345.97 (r/w/o: 39443.68/11268.19/5634.10) lat (ms,95%): 3.96 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 8 tps: 2841.99 qps: 56846.86 (r/w/o: 39793.90/11368.97/5683.99) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 8 tps: 2744.06 qps: 54877.24 (r/w/o: 38416.87/10972.25/5488.12) lat (ms,95%): 4.18 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 8 tps: 2820.93 qps: 56408.64 (r/w/o: 39479.05/11287.73/5641.86) lat (ms,95%): 4.03 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 8 tps: 2811.04 qps: 56212.89 (r/w/o: 39350.62/11240.18/5622.09) lat (ms,95%): 4.10 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 8 tps: 2811.96 qps: 56255.17 (r/w/o: 39379.42/11251.83/5623.92) lat (ms,95%): 3.89 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            575974
        write:                           164564
        other:                           82282
        total:                           822820
    transactions:                        41141  (2741.88 per sec.)
    queries:                             822820 (54837.61 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          15.0036s
    total number of events:              41141

Latency (ms):
         min:                                    1.21
         avg:                                    2.92
         max:                                   87.87
         95th percentile:                        4.03
         sum:                               119949.89

Threads fairness:
    events (avg/stddev):           5142.6250/23.98
    execution time (avg/stddev):   14.9937/0.00


sysbench mysql summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
read: 575974
write: 164564
other: 82282
total: 822820
transactions: 41141 (2741.88 per sec.)
queries: 822820 (54837.61 per sec.)
time: 15.0036s
min: 1.21
avg: 2.92
max: 87.87
95th: 4.03

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions: | queries: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 575974 | 164564 | 82282 | 822820 | 2741.88 | 54837.61 | 15.0036s | 1.21 | 2.92 | 87.87 | 4.03 |

sysbench,sysbench,threads,read,write,other,total,transactions,queries,time,min,avg,max,95th 
oltp.lua,1.0.14,8,575974,164564,82282,822820,2741.88,54837.61,15.0036s,1.21,2.92,87.87,4.03 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=8 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions: | queries: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 8 | 575974 | 164564 | 82282 | 822820 | 2741.88 | 54837.61 | 15.0036s | 1.21 | 2.92 | 87.87 | 4.03 |