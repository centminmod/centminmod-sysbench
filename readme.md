# sysbench.sh tool

`sysbench.sh` benchmark tool written specifically for [Centmin Mod LEMP stack](https://centminmod.com/) testing.

```
sysbench --version
sysbench 1.0.14
```

each `sysbench.sh` test option saves results into temporary log file in `/home/sysbench/` directory which gets overwritten after each script run.

```
ls -lh /home/sysbench/ 
total 68K
drwxr-xr-x 2 root root 4.0K May 24 04:24 fileio
-rw-r--r-- 1 root root  148 May 24 04:22 sysbench-cpu-threads-1.log
-rw-r--r-- 1 root root  150 May 24 04:22 sysbench-cpu-threads-8.log
-rw-r--r-- 1 root root  324 May 24 04:23 sysbench-fileio-rndrd-threads-1.log
-rw-r--r-- 1 root root  326 May 24 04:24 sysbench-fileio-rndrd-threads-8.log
-rw-r--r-- 1 root root  328 May 24 04:23 sysbench-fileio-rndrw-threads-1.log
-rw-r--r-- 1 root root  329 May 24 04:24 sysbench-fileio-rndrw-threads-8.log
-rw-r--r-- 1 root root  326 May 24 04:23 sysbench-fileio-rndwr-threads-1.log
-rw-r--r-- 1 root root  327 May 24 04:24 sysbench-fileio-rndwr-threads-8.log
-rw-r--r-- 1 root root  278 May 24 04:22 sysbench-fileio-seqrd-threads-1.log
-rw-r--r-- 1 root root  279 May 24 04:23 sysbench-fileio-seqrd-threads-8.log
-rw-r--r-- 1 root root  281 May 24 04:23 sysbench-fileio-seqrewr-threads-1.log
-rw-r--r-- 1 root root  282 May 24 04:24 sysbench-fileio-seqrewr-threads-8.log
-rw-r--r-- 1 root root  291 May 24 04:23 sysbench-fileio-seqwr-threads-1.log
-rw-r--r-- 1 root root  291 May 24 04:24 sysbench-fileio-seqwr-threads-8.log
-rw-r--r-- 1 root root  257 May 24 04:22 sysbench-mem-threads-1.log
-rw-r--r-- 1 root root  259 May 24 04:22 sysbench-mem-threads-8.log
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
events/s: 525.85
time: 10.0016s
min: 1.90
avg: 1.90
max: 2.35
95th: 1.89

sysbench cpu --cpu-max-prime=20000 --threads=8 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
prime: 20000
events/s: 3224.91
time: 10.0022s
min: 1.90
avg: 2.48
max: 23.65
95th: 2.48
```

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
total-ops: 1048576 (8181671.73 per second)
transferred (7989.91 MiB/sec)
time: 0.1269s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

sysbench memory --threads=8 --memory-block-size=1K --memory-scope=global --memory-total-size=1G --memory-oper=read run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
block-size: 1KiB
total-size: 1024MiB
operation: read
scope: global
total-ops: 1048576 (32920206.58 per second)
transferred (32148.64 MiB/sec)
time: 0.0306s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00
```

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
reads/s: 1215381.25
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 4689.24
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24586.96
fsyncs/s: 31468.51
read-MiB/s: 0.00
written-MiB/s: 94.86
time: 10.0000s
min: 0.00
avg: 0.02
max: 1.35
95th: 0.03

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24575.91
fsyncs/s: 31456.47
read-MiB/s: 0.00
written-MiB/s: 94.82
time: 10.0004s
min: 0.00
avg: 0.02
max: 3.85
95th: 0.03

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 983721.80
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 3817.13
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.01
95th: 0.00

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 14698.13
fsyncs/s: 18802.41
read-MiB/s: 0.00
written-MiB/s: 57.05
time: 10.0000s
min: 0.00
avg: 0.03
max: 0.81
95th: 0.08

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 12424.45
writes/s: 8282.97
fsyncs/s: 26499.10
read-MiB/s: 48.20
written-MiB/s: 32.13
time: 10.0000s
min: 0.00
avg: 0.02
max: 5.55
95th: 0.07

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 2838044.62
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 10949.87
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 4.05
95th: 0.00

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24936.76
fsyncs/s: 31911.35
read-MiB/s: 0.00
written-MiB/s: 96.21
time: 10.0002s
min: 0.00
avg: 0.14
max: 23.05
95th: 0.13

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24986.76
fsyncs/s: 31981.65
read-MiB/s: 0.00
written-MiB/s: 96.41
time: 10.0002s
min: 0.00
avg: 0.14
max: 27.08
95th: 0.13

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 2530196.45
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 9818.03
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 28.08
95th: 0.00

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 18027.43
fsyncs/s: 23063.92
read-MiB/s: 0.00
written-MiB/s: 69.95
time: 10.0002s
min: 0.00
avg: 0.19
max: 14.45
95th: 0.90

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-io-mode=sync --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 14097.93
writes/s: 9398.79
fsyncs/s: 30065.60
read-MiB/s: 54.72
written-MiB/s: 36.47
time: 10.0002s
min: 0.00
avg: 0.15
max: 18.12
95th: 0.69

sysbench fileio cleanup
sysbench fileio --file-total-size=38320634 cleanup
```