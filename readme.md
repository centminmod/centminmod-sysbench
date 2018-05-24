# sysbench.sh tool

`sysbench.sh` benchmark tool written specificy for [Centmin Mod LEMP stack](https://centminmod.com/) testing.

```
sysbench --version
sysbench 1.0.14
```

## sysbench install

```
./sysbench.sh install
```

## sysbench usage

```
Usage:
./sysbench.sh {install|cpu|mem|file|mysql}
```

## sysbench cpu

```
./sysbench.sh cpu

threads: 1
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

threads: 8
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

threads: 1
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

threads: 8
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

threads: 1
sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 1240534.66
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 4786.29
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.02
95th: 0.00

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24556.83
fsyncs/s: 31431.75
read-MiB/s: 0.00
written-MiB/s: 94.75
time: 10.0001s
min: 0.00
avg: 0.02
max: 9.96
95th: 0.03

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 24596.93
fsyncs/s: 31482.37
read-MiB/s: 0.00
written-MiB/s: 94.90
time: 10.0000s
min: 0.00
avg: 0.02
max: 4.97
95th: 0.03

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 1012370.33
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 3928.33
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 0.03
95th: 0.00

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 14618.12
fsyncs/s: 18703.40
read-MiB/s: 0.00
written-MiB/s: 56.73
time: 10.0001s
min: 0.00
avg: 0.03
max: 12.36
95th: 0.08

sysbench fileio --threads=1 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 1
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 12388.44
writes/s: 8258.96
fsyncs/s: 26418.57
read-MiB/s: 48.08
written-MiB/s: 32.04
time: 10.0000s
min: 0.00
avg: 0.02
max: 0.56
95th: 0.07

threads: 8
sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential read test
reads/s: 2836508.07
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 10943.94
written-MiB/s: 0.00
time: 10.0001s
min: 0.00
avg: 0.00
max: 20.80
95th: 0.00

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential write (creation) test
reads/s: 0.00
writes/s: 24986.77
fsyncs/s: 31976.47
read-MiB/s: 0.00
written-MiB/s: 96.41
time: 10.0002s
min: 0.00
avg: 0.14
max: 28.51
95th: 0.13

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=seqrewr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Using synchronous I/O mode
Doing sequential rewrite test
reads/s: 0.00
writes/s: 25046.73
fsyncs/s: 32058.51
read-MiB/s: 0.00
written-MiB/s: 96.64
time: 10.0002s
min: 0.00
avg: 0.14
max: 23.95
95th: 0.13

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndrd --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random read test
reads/s: 2538339.29
writes/s: 0.00
fsyncs/s: 0.00
read-MiB/s: 9849.58
written-MiB/s: 0.00
time: 10.0000s
min: 0.00
avg: 0.00
max: 21.57
95th: 0.00

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndwr --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random write test
reads/s: 0.00
writes/s: 17987.44
fsyncs/s: 23020.33
read-MiB/s: 0.00
written-MiB/s: 69.80
time: 10.0002s
min: 0.00
avg: 0.19
max: 12.74
95th: 0.90

sysbench fileio --threads=8 --file-total-size=38320634 --file-block-size=4096 --file-test-mode=rndrw --time=10 --events=0 run
sysbench 1.0.14 (using bundled LuaJIT 2.1.0-beta2)
threads: 8
Block-size 4KiB
Read/Write ratio for combined random IO test: 1.50
Using synchronous I/O mode
Doing random r/w test
reads/s: 14139.98
writes/s: 9426.65
fsyncs/s: 30153.08
read-MiB/s: 54.85
written-MiB/s: 36.59
time: 10.0002s
min: 0.00
avg: 0.15
max: 13.39
95th: 0.69

sysbench fileio cleanup
sysbench fileio --file-total-size=38320634 cleanup
```