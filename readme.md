# sysbench.sh tool

`sysbench.sh` benchmark tool written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing.

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
events/s: 525.26
time: 10.0015s
min: 1.90
avg: 1.90
max: 2.37
95th: 1.89

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.26 | 10.0015s | 1.90 | 1.90 | 2.37 | 1.89 |

sysbench cpu --cpu-max-prime=20000 --threads=8 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
prime: 20000
events/s: 3230.55
time: 10.0023s
min: 1.90
avg: 2.47
max: 31.49
95th: 2.48

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 8 | 3230.55 | 10.0023s | 1.90 | 2.47 | 31.49 | 2.48 |
```

Markdown results table

| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.14 | 1 | 525.26 | 10.0015s | 1.90 | 1.90 | 2.37 | 1.89 |
| 1.0.14 | 8 | 3230.55 | 10.0023s | 1.90 | 2.47 | 31.49 | 2.48 |

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
total-ops: 1048576 (8190991.10 per second)
transferred (7999.01 MiB/sec)
time: 0.1268s
min: 0.00
avg: 0.00
max: 0.00
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7999.01 | 0.1268s | 0.00 | 0.00 | 0.00 | 0.00 |

sysbench memory --threads=8 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (27294954.00 per second)
transferred (26655.23 MiB/sec)
time: 0.0372s
min: 0.00
avg: 0.00
max: 0.02
95th: 0.00

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 26655.23 | 0.0372s | 0.00 | 0.00 | 0.02 | 0.00 |
```

Markdown results table

| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| memory | 1.0.14 | 1 | 1KiB | 1024MiB | read | 1048576 | 7999.01 | 0.1268s | 0.00 | 0.00 | 0.00 | 0.00 |
| memory | 1.0.14 | 8 | 1KiB | 1024MiB | read | 1048576 | 26655.23 | 0.0372s | 0.00 | 0.00 | 0.02 | 0.00 |

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
reads/s: 1239884.48
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 4783.78
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1239884.48 | 0.00 | 0.00 | 4783.78 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24566.93
fsyncs/s: 31441.87
read-MiB/s: 0.00
written-MiB/s: 94.79
time: 10.0000s
min: 0.00
avg: 0.02
max: 5.31
95th: 0.03

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24566.93 | 31441.87 | 0.00 | 94.79 | 10.0000s | 0.00 | 0.02 | 5.31 | 0.03 |

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24646.92
fsyncs/s: 31537.16
read-MiB/s: 0.00
written-MiB/s: 95.09
time: 10.0000s
min: 0.00
avg: 0.02
max: 0.86
95th: 0.02

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 24646.92 | 31537.16 | 0.00 | 95.09 | 10.0000s | 0.00 | 0.02 | 0.86 | 0.02 |

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 988258.91
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 3834.72
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | read | 988258.91 | 0.00 | 0.00 | 3834.72 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 14668.12
fsyncs/s: 18772.89
read-MiB/s: 0.00
written-MiB/s: 56.90
time: 10.0001s
min: 0.00
avg: 0.03
max: 1.76
95th: 0.08

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14668.12 | 18772.89 | 0.00 | 56.90 | 10.0001s | 0.00 | 0.03 | 1.76 | 0.08 |

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 12343.05
writes/s: 8228.77
fsyncs/s: 26326.30
read-MiB/s: 47.91
written-MiB/s: 31.92
time: 10.0000s
min: 0.00
avg: 0.02
max: 2.81
95th: 0.07

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12343.05 | 8228.77 | 26326.30 | 47.91 | 31.92 | 10.0000s | 0.00 | 0.02 | 2.81 | 0.07 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 2805518.98
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 10824.38
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 6.88
95th: 0.00

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2805518.98 | 0.00 | 0.00 | 10824.38 | 0.00 | 10.0001s | 0.00 | 0.00 | 6.88 | 0.00 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24826.67
fsyncs/s: 31766.54
read-MiB/s: 0.00
written-MiB/s: 95.79
time: 10.0002s
min: 0.00
avg: 0.14
max: 28.22
95th: 0.12

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24826.67 | 31766.54 | 0.00 | 95.79 | 10.0002s | 0.00 | 0.14 | 28.22 | 0.12 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24905.15
fsyncs/s: 31869.69
read-MiB/s: 0.00
written-MiB/s: 96.09
time: 10.0009s
min: 0.00
avg: 0.14
max: 28.20
95th: 0.09

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24905.15 | 31869.69 | 0.00 | 96.09 | 10.0009s | 0.00 | 0.14 | 28.20 | 0.09 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 2470349.69
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 9585.81
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 22.03
95th: 0.01

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2470349.69 | 0.00 | 0.00 | 9585.81 | 0.00 | 10.0001s | 0.00 | 0.00 | 22.03 | 0.01 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 18007.40
fsyncs/s: 23038.47
read-MiB/s: 0.00
written-MiB/s: 69.88
time: 10.0002s
min: 0.00
avg: 0.19
max: 14.15
95th: 0.90

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 18007.40 | 23038.47 | 0.00 | 69.88 | 10.0002s | 0.00 | 0.19 | 14.15 | 0.90 |

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 14019.96
writes/s: 9346.80
fsyncs/s: 29909.15
read-MiB/s: 54.41
written-MiB/s: 36.26
time: 10.0002s
min: 0.00
avg: 0.15
max: 15.07
95th: 0.69

| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14019.96 | 9346.80 | 29909.15 | 54.41 | 36.26 | 10.0002s | 0.00 | 0.15 | 15.07 | 0.69 |

sysbench fileio cleanup
sysbench fileio --file-total-size=38320634 cleanup
```

Parsing sysbench fileio for markdown table

```
ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1234307.50 | 0.00 | 0.00 | 4762.26 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24526.95 | 31387.19 | 0.00 | 94.63 | 10.0000s | 0.00 | 0.02 | 1.34 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 24616.93 | 31509.06 | 0.00 | 94.98 | 10.0000s | 0.00 | 0.02 | 6.10 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1003387.16 | 0.00 | 0.00 | 3893.47 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14598.16 | 18680.84 | 0.00 | 56.65 | 10.0000s | 0.00 | 0.03 | 5.94 | 0.08 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12328.42 | 8218.95 | 26297.64 | 47.84 | 31.89 | 10.0000s | 0.00 | 0.02 | 2.65 | 0.07 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2753621.37 | 0.00 | 0.00 | 10624.14 | 0.00 | 10.0001s | 0.00 | 0.00 | 19.30 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24846.74 | 31791.53 | 0.00 | 95.86 | 10.0002s | 0.00 | 0.14 | 24.03 | 0.11 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24906.77 | 31874.87 | 0.00 | 96.10 | 10.0002s | 0.00 | 0.14 | 52.63 | 0.10 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2478120.61 | 0.00 | 0.00 | 9616.11 | 0.00 | 10.0000s | 0.00 | 0.00 | 16.05 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 17947.42 | 22966.20 | 0.00 | 69.64 | 10.0002s | 0.00 | 0.20 | 12.73 | 0.90 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14007.73 | 9338.65 | 29872.27 | 54.36 | 36.24 | 10.0003s | 0.00 | 0.15 | 11.08 | 0.70 |
```

Markdown results table

| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1234307.50 | 0.00 | 0.00 | 4762.26 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 24526.95 | 31387.19 | 0.00 | 94.63 | 10.0000s | 0.00 | 0.02 | 1.34 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | rewrite | 0.00 | 24616.93 | 31509.06 | 0.00 | 94.98 | 10.0000s | 0.00 | 0.02 | 6.10 | 0.03 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | read | 1003387.16 | 0.00 | 0.00 | 3893.47 | 0.00 | 10.0000s | 0.00 | 0.00 | 0.01 | 0.00 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | write | 0.00 | 14598.16 | 18680.84 | 0.00 | 56.65 | 10.0000s | 0.00 | 0.03 | 5.94 | 0.08 |
|fileio | 1.0.14 | 1 | 4KiB | I/O | r/w | 12328.42 | 8218.95 | 26297.64 | 47.84 | 31.89 | 10.0000s | 0.00 | 0.02 | 2.65 | 0.07 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2753621.37 | 0.00 | 0.00 | 10624.14 | 0.00 | 10.0001s | 0.00 | 0.00 | 19.30 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 24846.74 | 31791.53 | 0.00 | 95.86 | 10.0002s | 0.00 | 0.14 | 24.03 | 0.11 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | rewrite | 0.00 | 24906.77 | 31874.87 | 0.00 | 96.10 | 10.0002s | 0.00 | 0.14 | 52.63 | 0.10 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | read | 2478120.61 | 0.00 | 0.00 | 9616.11 | 0.00 | 10.0000s | 0.00 | 0.00 | 16.05 | 0.00 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | write | 0.00 | 17947.42 | 22966.20 | 0.00 | 69.64 | 10.0002s | 0.00 | 0.20 | 12.73 | 0.90 |
|fileio | 1.0.14 | 8 | 4KiB | I/O | r/w | 14007.73 | 9338.65 | 29872.27 | 54.36 | 36.24 | 10.0003s | 0.00 | 0.15 | 11.08 | 0.70 |