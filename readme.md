# sysbench.sh tool

`sysbench.sh` benchmark tool written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing. Results are displayed in 3 formats, standard, github markdown and CSV comma separated.

```
sysbench --version
sysbench 1.0.14
```

each `sysbench.sh` test option saves results into temporary log file in `/home/sysbench/` directory which gets overwritten after each script run.

```
ls -lh /home/sysbench/
total 124K
drwxr-xr-x 2 root root 4.0K May 24 07:07 fileio
-rw-r--r-- 1 root root  199 May 24 06:56 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  182 May 24 06:56 sysbench-cpu-threads-1-markdown.log
-rw-r--r-- 1 root root  201 May 24 06:57 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  184 May 24 06:57 sysbench-cpu-threads-8-markdown.log
-rw-r--r-- 1 root root  471 May 24 07:06 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  395 May 24 07:06 sysbench-fileio-rndrd-threads-1-markdown.log
-rw-r--r-- 1 root root  472 May 24 07:07 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  396 May 24 07:07 sysbench-fileio-rndrd-threads-8-markdown.log
-rw-r--r-- 1 root root  474 May 24 07:06 sysbench-fileio-rndrw-threads-1.log
-rw-r--r-- 1 root root  398 May 24 07:06 sysbench-fileio-rndrw-threads-1-markdown.log
-rw-r--r-- 1 root root  475 May 24 07:07 sysbench-fileio-rndrw-threads-8.log
-rw-r--r-- 1 root root  399 May 24 07:07 sysbench-fileio-rndrw-threads-8-markdown.log
-rw-r--r-- 1 root root  472 May 24 07:06 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  396 May 24 07:06 sysbench-fileio-rndwr-threads-1-markdown.log
-rw-r--r-- 1 root root  473 May 24 07:07 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  397 May 24 07:07 sysbench-fileio-rndwr-threads-8-markdown.log
-rw-r--r-- 1 root root  424 May 24 07:05 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  399 May 24 07:05 sysbench-fileio-seqrd-threads-1-markdown.log
-rw-r--r-- 1 root root  426 May 24 07:06 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  401 May 24 07:06 sysbench-fileio-seqrd-threads-8-markdown.log
-rw-r--r-- 1 root root  429 May 24 07:05 sysbench-fileio-seqrewr-threads-1.log
-rw-r--r-- 1 root root  402 May 24 07:05 sysbench-fileio-seqrewr-threads-1-markdown.log
-rw-r--r-- 1 root root  430 May 24 07:06 sysbench-fileio-seqrewr-threads-8.log
-rw-r--r-- 1 root root  403 May 24 07:06 sysbench-fileio-seqrewr-threads-8-markdown.log
-rw-r--r-- 1 root root  436 May 24 07:05 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  400 May 24 07:05 sysbench-fileio-seqwr-threads-1-markdown.log
-rw-r--r-- 1 root root  437 May 24 07:06 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  401 May 24 07:06 sysbench-fileio-seqwr-threads-8-markdown.log
-rw-r--r-- 1 root root  376 May 24 06:47 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  378 May 24 06:47 sysbench-mem-threads-8.log
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