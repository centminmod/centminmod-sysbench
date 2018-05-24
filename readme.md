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
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=2 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql prepare
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
| sbt.sbtest1 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Dynamic    | utf8_general_ci |
| sbt.sbtest2 | 98712 Rows     | InnoDB         | 21.55MB   | 1.52MB     | 23.06MB | Dynamic    | utf8_general_ci |
| sbt.sbtest3 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Dynamic    | utf8_general_ci |
| sbt.sbtest4 | 100000 Rows    | InnoDB         | 0.02MB    | 0.00MB     | 0.02MB  | Dynamic    | utf8_general_ci |
+-------------+----------------+----------------+-----------+------------+---------+------------+-----------------+

sysbench mysql benchmark:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=2 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Running the test with following options:
Number of threads: 2
Report intermediate results every 1 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 1s ] thds: 2 tps: 452.65 qps: 9079.00 (r/w/o: 6357.10/1814.60/907.30) lat (ms,95%): 8.58 err/s: 0.00 reconn/s: 0.00
[ 2s ] thds: 2 tps: 431.04 qps: 8620.73 (r/w/o: 6038.51/1720.15/862.07) lat (ms,95%): 9.91 err/s: 0.00 reconn/s: 0.00
[ 3s ] thds: 2 tps: 506.03 qps: 10110.58 (r/w/o: 7074.41/2024.12/1012.06) lat (ms,95%): 6.67 err/s: 0.00 reconn/s: 0.00
[ 4s ] thds: 2 tps: 534.08 qps: 10690.61 (r/w/o: 7486.13/2136.32/1068.16) lat (ms,95%): 6.43 err/s: 0.00 reconn/s: 0.00
[ 5s ] thds: 2 tps: 505.84 qps: 10111.89 (r/w/o: 7076.83/2023.38/1011.69) lat (ms,95%): 6.43 err/s: 0.00 reconn/s: 0.00
[ 6s ] thds: 2 tps: 490.08 qps: 9813.67 (r/w/o: 6869.17/1964.33/980.17) lat (ms,95%): 7.30 err/s: 0.00 reconn/s: 0.00
[ 7s ] thds: 2 tps: 492.01 qps: 9834.13 (r/w/o: 6882.09/1968.03/984.01) lat (ms,95%): 8.13 err/s: 0.00 reconn/s: 0.00
[ 8s ] thds: 2 tps: 517.99 qps: 10350.71 (r/w/o: 7246.80/2067.94/1035.97) lat (ms,95%): 6.79 err/s: 0.00 reconn/s: 0.00
[ 9s ] thds: 2 tps: 491.02 qps: 9828.46 (r/w/o: 6882.32/1964.09/982.05) lat (ms,95%): 7.17 err/s: 0.00 reconn/s: 0.00
[ 10s ] thds: 2 tps: 503.03 qps: 10071.64 (r/w/o: 7047.45/2018.13/1006.06) lat (ms,95%): 6.55 err/s: 0.00 reconn/s: 0.00
[ 11s ] thds: 2 tps: 539.03 qps: 10765.50 (r/w/o: 7537.35/2150.10/1078.05) lat (ms,95%): 6.21 err/s: 0.00 reconn/s: 0.00
[ 12s ] thds: 2 tps: 532.91 qps: 10663.23 (r/w/o: 7465.76/2131.65/1065.82) lat (ms,95%): 6.55 err/s: 0.00 reconn/s: 0.00
[ 13s ] thds: 2 tps: 521.00 qps: 10425.08 (r/w/o: 7297.06/2086.02/1042.01) lat (ms,95%): 6.67 err/s: 0.00 reconn/s: 0.00
[ 14s ] thds: 2 tps: 548.08 qps: 10941.65 (r/w/o: 7655.15/2190.33/1096.17) lat (ms,95%): 6.09 err/s: 0.00 reconn/s: 0.00
[ 15s ] thds: 2 tps: 497.00 qps: 9952.91 (r/w/o: 6970.94/1987.98/993.99) lat (ms,95%): 8.43 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            105910
        write:                           30260
        other:                           15130
        total:                           151300
    transactions:                        7565   (504.13 per sec.)
    queries:                             151300 (10082.64 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          15.0039s
    total number of events:              7565

Latency (ms):
         min:                                    2.79
         avg:                                    3.96
         max:                                  102.68
         95th percentile:                        7.04
         sum:                                29978.92

Threads fairness:
    events (avg/stddev):           3782.5000/13.50
    execution time (avg/stddev):   14.9895/0.00


sysbench mysql summary:
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=2 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 2
read: 105910
write: 30260
other: 15130
total: 151300
transactions: 7565 (504.13 per sec.)
queries: 151300 (10082.64 per sec.)
time: 15.0039s
min: 2.79
avg: 3.96
max: 102.68
95th: 7.04

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions: | queries: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 2 | 105910 | 30260 | 15130 | 151300 | 7565 | 151300 | 15.0039s | 2.79 | 3.96 | 102.68 | 7.04 |

sysbench,sysbench,threads,read,write,other,total,transactions,queries,time,min,avg,max,95th 
oltp.lua,1.0.14,2,105910,30260,15130,151300,7565,151300,15.0039s,2.79,3.96,102.68,7.04 

sysbench mysql cleanup database: sbt
sysbench oltp.lua --mysql-host=localhost --mysql-port=3306 --mysql-user=sbtest --mysql-password=sbtestpass --mysql-db=sbt --time=15 --threads=2 --report-interval=1 --oltp-table-size=100000 --oltp-tables-count=4 --db-driver=mysql cleanup
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)

Dropping table 'sbtest1'...
Dropping table 'sbtest2'...
Dropping table 'sbtest3'...
Dropping table 'sbtest4'...
```

| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions: | queries: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| oltp.lua | 1.0.14 | 2 | 105910 | 30260 | 15130 | 151300 | 7565 | 151300 | 15.0039s | 2.79 | 3.96 | 102.68 | 7.04 |