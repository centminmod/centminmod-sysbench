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
total 160K
drwxr-xr-x 2 root root 4.0K May 24 07:43 fileio
drwxr-xr-x 2 root root 4.0K May 24 16:47 mysql
-rw-r--r-- 1 root root  199 May 24 07:39 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  182 May 24 07:39 sysbench-cpu-threads-1-markdown.log
-rw-r--r-- 1 root root  201 May 24 07:39 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  184 May 24 07:39 sysbench-cpu-threads-8-markdown.log
-rw-r--r-- 1 root root  470 May 24 07:42 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  394 May 24 07:42 sysbench-fileio-rndrd-threads-1-markdown.log
-rw-r--r-- 1 root root  471 May 24 07:43 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  395 May 24 07:43 sysbench-fileio-rndrd-threads-8-markdown.log
-rw-r--r-- 1 root root  474 May 24 07:42 sysbench-fileio-rndrw-threads-1.log
-rw-r--r-- 1 root root  398 May 24 07:42 sysbench-fileio-rndrw-threads-1-markdown.log
-rw-r--r-- 1 root root  475 May 24 07:43 sysbench-fileio-rndrw-threads-8.log
-rw-r--r-- 1 root root  399 May 24 07:43 sysbench-fileio-rndrw-threads-8-markdown.log
-rw-r--r-- 1 root root  472 May 24 07:42 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  396 May 24 07:42 sysbench-fileio-rndwr-threads-1-markdown.log
-rw-r--r-- 1 root root  473 May 24 07:43 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  397 May 24 07:43 sysbench-fileio-rndwr-threads-8-markdown.log
-rw-r--r-- 1 root root  424 May 24 07:41 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  399 May 24 07:41 sysbench-fileio-seqrd-threads-1-markdown.log
-rw-r--r-- 1 root root  426 May 24 07:42 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  401 May 24 07:42 sysbench-fileio-seqrd-threads-8-markdown.log
-rw-r--r-- 1 root root  430 May 24 07:42 sysbench-fileio-seqrewr-threads-1.log
-rw-r--r-- 1 root root  403 May 24 07:42 sysbench-fileio-seqrewr-threads-1-markdown.log
-rw-r--r-- 1 root root  430 May 24 07:43 sysbench-fileio-seqrewr-threads-8.log
-rw-r--r-- 1 root root  403 May 24 07:43 sysbench-fileio-seqrewr-threads-8-markdown.log
-rw-r--r-- 1 root root  436 May 24 07:42 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  400 May 24 07:42 sysbench-fileio-seqwr-threads-1-markdown.log
-rw-r--r-- 1 root root  437 May 24 07:43 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  401 May 24 07:43 sysbench-fileio-seqwr-threads-8-markdown.log
-rw-r--r-- 1 root root  376 May 24 07:41 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  322 May 24 07:41 sysbench-mem-threads-1-markdown.log
-rw-r--r-- 1 root root  378 May 24 07:41 sysbench-mem-threads-8.log
-rw-r--r-- 1 root root  323 May 24 07:41 sysbench-mem-threads-8-markdown.log
-rw-r--r-- 1 root root  401 May 24 16:49 sysbench-mysql-cleanup-threads-8.log
-rw-r--r-- 1 root root  733 May 24 16:48 sysbench-mysql-prepare-threads-8.log
-rw-r--r-- 1 root root  481 May 24 16:49 sysbench-mysql-run-summary-threads-8.log
-rw-r--r-- 1 root root  334 May 24 16:49 sysbench-mysql-run-summary-threads-8-markdown.log
-rw-r--r-- 1 root root 3.3K May 24 16:49 sysbench-mysql-run-threads-8.log
-rw-r--r-- 1 root root  928 May 24 16:48 sysbench-mysql-table-list.log
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

```
./sysbench.sh file

sysbench fileio prepare
sysbench fileio --file-total-size=38320634 prepare

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 1242982.62
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 4795.73
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1242982.62 | 0.00 | 0.00 | 4795.73 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,read,1242982.62,0.00,0.00,4795.73,0.00,10.0000s,0.00,0.00,0.01,0.00 

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24536.84
fsyncs/s: 31406.66
read-MiB/s: 0.00
written-MiB/s: 94.67
time: 10.0001s
min: 0.00
avg: 0.02
max: 1.02
95th: 0.03

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24536.84 | 31406.66 | 0.00 | 94.67 | 10.0001s | 0.00 | 0.02 | 1.02 | 0.03 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,write,0.00,24536.84,31406.66,0.00,94.67,10.0001s,0.00,0.02,1.02,0.03 

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 23997.00
fsyncs/s: 30707.46
read-MiB/s: 0.00
written-MiB/s: 92.59
time: 10.0000s
min: 0.00
avg: 0.02
max: 10.01
95th: 0.03

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 23997.00 | 30707.46 | 0.00 | 92.59 | 10.0000s | 0.00 | 0.02 | 10.01 | 0.03 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,rewrite,0.00,23997.00,30707.46,0.00,92.59,10.0000s,0.00,0.02,10.01,0.03 

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 983698.35
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 3817.14
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.02
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 983698.35 | 0.00 | 0.00 | 3817.14 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.02 | 0.00 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,read,983698.35,0.00,0.00,3817.14,0.00,10.0000s,0.00,0.00,0.02,0.00 

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 14558.14
fsyncs/s: 18633.12
read-MiB/s: 0.00
written-MiB/s: 56.49
time: 10.0000s
min: 0.00
avg: 0.03
max: 2.06
95th: 0.09

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14558.14 | 18633.12 | 0.00 | 56.49 | 10.0000s | 0.00 | 0.03 | 2.06 | 0.09 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,write,0.00,14558.14,18633.12,0.00,56.49,10.0000s,0.00,0.03,2.06,0.09 

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 12346.40
writes/s: 8230.93
fsyncs/s: 26329.48
read-MiB/s: 47.91
written-MiB/s: 31.94
time: 10.0001s
min: 0.00
avg: 0.02
max: 2.93
95th: 0.07

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12346.40 | 8230.93 | 26329.48 | 47.91 | 31.94 | 10.0001s | 0.00 | 0.02 | 2.93 | 0.07 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,1,4KiB,I/O,r/w,12346.40,8230.93,26329.48,47.91,31.94,10.0001s,0.00,0.02,2.93,0.07 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 2720918.99
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 10497.97
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 15.15
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2720918.99 | 0.00 | 0.00 | 10497.97 | 0.00 | 10.0001s | 0.00 | 0.00 | 15.15 | 0.00 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,read,2720918.99,0.00,0.00,10497.97,0.00,10.0001s,0.00,0.00,15.15,0.00 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24816.74
fsyncs/s: 31762.82
read-MiB/s: 0.00
written-MiB/s: 95.75
time: 10.0002s
min: 0.00
avg: 0.14
max: 31.86
95th: 0.10

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24816.74 | 31762.82 | 0.00 | 95.75 | 10.0002s | 0.00 | 0.14 | 31.86 | 0.10 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,write,0.00,24816.74,31762.82,0.00,95.75,10.0002s,0.00,0.14,31.86,0.10 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24866.73
fsyncs/s: 31823.82
read-MiB/s: 0.00
written-MiB/s: 95.94
time: 10.0002s
min: 0.00
avg: 0.14
max: 29.13
95th: 0.09

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24866.73 | 31823.82 | 0.00 | 95.94 | 10.0002s | 0.00 | 0.14 | 29.13 | 0.09 |

sysbench,sysbench,threads,Block-size,synchronous,sequential,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,rewrite,0.00,24866.73,31823.82,0.00,95.94,10.0002s,0.00,0.14,29.13,0.09 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 2473427.76
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 9597.80
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 5.12
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2473427.76 | 0.00 | 0.00 | 9597.80 | 0.00 | 10.0000s | 0.00 | 0.00 | 5.12 | 0.00 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,read,2473427.76,0.00,0.00,9597.80,0.00,10.0000s,0.00,0.00,5.12,0.00 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 17927.45
fsyncs/s: 22945.14
read-MiB/s: 0.00
written-MiB/s: 69.57
time: 10.0002s
min: 0.00
avg: 0.20
max: 12.57
95th: 0.90

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 17927.45 | 22945.14 | 0.00 | 69.57 | 10.0002s | 0.00 | 0.20 | 12.57 | 0.90 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,write,0.00,17927.45,22945.14,0.00,69.57,10.0002s,0.00,0.20,12.57,0.90 

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 14031.84
writes/s: 9354.73
fsyncs/s: 29925.61
read-MiB/s: 54.45
written-MiB/s: 36.29
time: 10.0002s
min: 0.00
avg: 0.15
max: 11.02
95th: 0.70

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14031.84 | 9354.73 | 29925.61 | 54.45 | 36.29 | 10.0002s | 0.00 | 0.15 | 11.02 | 0.70 |

sysbench,sysbench,threads,Block-size,synchronous,random,reads/s,writes/s,fsyncs/s,read-MiB/s,written-MiB/s,time,min,avg,max,95th 
fileio,1.0.14,8,4KiB,I/O,r/w,14031.84,9354.73,29925.61,54.45,36.29,10.0002s,0.00,0.15,11.02,0.70 

sysbench fileio cleanup
sysbench fileio --file-total-size=38320634 cleanup
```

Parsing sysbench fileio for markdown table

Sequential

```
ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'seq' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1242982.62 | 0.00 | 0.00 | 4795.73 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24536.84 | 31406.66 | 0.00 | 94.67 | 10.0001s | 0.00 | 0.02 | 1.02 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 23997.00 | 30707.46 | 0.00 | 92.59 | 10.0000s | 0.00 | 0.02 | 10.01 | 0.03 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2720918.99 | 0.00 | 0.00 | 10497.97 | 0.00 | 10.0001s | 0.00 | 0.00 | 15.15 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24816.74 | 31762.82 | 0.00 | 95.75 | 10.0002s | 0.00 | 0.14 | 31.86 | 0.10 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24866.73 | 31823.82 | 0.00 | 95.94 | 10.0002s | 0.00 | 0.14 | 29.13 | 0.09 |
```

Random

```
ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'rnd' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 983698.35 | 0.00 | 0.00 | 3817.14 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.02 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14558.14 | 18633.12 | 0.00 | 56.49 | 10.0000s | 0.00 | 0.03 | 2.06 | 0.09 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12346.40 | 8230.93 | 26329.48 | 47.91 | 31.94 | 10.0001s | 0.00 | 0.02 | 2.93 | 0.07 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2473427.76 | 0.00 | 0.00 | 9597.80 | 0.00 | 10.0000s | 0.00 | 0.00 | 5.12 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 17927.45 | 22945.14 | 0.00 | 69.57 | 10.0002s | 0.00 | 0.20 | 12.57 | 0.90 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14031.84 | 9354.73 | 29925.61 | 54.45 | 36.29 | 10.0002s | 0.00 | 0.15 | 11.02 | 0.70 |
```

Markdown results table - sequential

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1242982.62 | 0.00 | 0.00 | 4795.73 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24536.84 | 31406.66 | 0.00 | 94.67 | 10.0001s | 0.00 | 0.02 | 1.02 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 23997.00 | 30707.46 | 0.00 | 92.59 | 10.0000s | 0.00 | 0.02 | 10.01 | 0.03 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2720918.99 | 0.00 | 0.00 | 10497.97 | 0.00 | 10.0001s | 0.00 | 0.00 | 15.15 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24816.74 | 31762.82 | 0.00 | 95.75 | 10.0002s | 0.00 | 0.14 | 31.86 | 0.10 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24866.73 | 31823.82 | 0.00 | 95.94 | 10.0002s | 0.00 | 0.14 | 29.13 | 0.09 |

Markdown results table - random

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 983698.35 | 0.00 | 0.00 | 3817.14 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.02 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14558.14 | 18633.12 | 0.00 | 56.49 | 10.0000s | 0.00 | 0.03 | 2.06 | 0.09 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12346.40 | 8230.93 | 26329.48 | 47.91 | 31.94 | 10.0001s | 0.00 | 0.02 | 2.93 | 0.07 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2473427.76 | 0.00 | 0.00 | 9597.80 | 0.00 | 10.0000s | 0.00 | 0.00 | 5.12 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 17927.45 | 22945.14 | 0.00 | 69.57 | 10.0002s | 0.00 | 0.20 | 12.57 | 0.90 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14031.84 | 9354.73 | 29925.61 | 54.45 | 36.29 | 10.0002s | 0.00 | 0.15 | 11.02 | 0.70 |

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