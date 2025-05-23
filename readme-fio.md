FIO 3.40 RPMs for RedHat, AlmaLinux, Rocky Linux, Oracle Linux based EL8, EL9, EL10 for more consistent benchmark comparisons using same FIO version.

```bash
dnf info fio -q
Installed Packages
Name         : fio
Version      : 3.40
Release      : 1.el10
Architecture : x86_64
Size         : 8.9 M
Source       : fio-3.40-1.el10.src.rpm
Repository   : @System
From repo    : @commandline
Summary      : Multithreaded IO generation tool
URL          : http://git.kernel.dk/?p=fio.git;a=summary
License      : GPL-2.0-only
Description  : fio is an I/O tool that will spawn a number of threads or processes doing
             : a particular type of io action as specified by the user.  fio takes a
             : number of global parameters, each inherited by the thread unless
             : otherwise parameters given to them overriding that setting is given.
             : The typical use of fio is to write a job file matching the io load
             : one wants to simulate.
```

```bash
fio --help
fio-3.40
fio [options] [job options] <job file(s)>
  --debug=options       Enable debug logging. May be one/more of:
                        process,file,io,mem,blktrace,verify,random,parse,
                        diskutil,job,mutex,profile,time,net,rate,compress,
                        steadystate,helperthread,zbd
  --parse-only          Parse options only, don't start any IO
  --merge-blktrace-only Merge blktraces only, don't start any IO
  --output              Write output to file
  --bandwidth-log       Generate aggregate bandwidth logs
  --minimal             Minimal (terse) output
  --output-format=type  Output format (terse,json,json+,normal)
  --terse-version=type  Set terse version output format (default 3, or 2 or 4 or 5)
  --version             Print version info and exit
  --help                Print this page
  --cpuclock-test       Perform test/validation of CPU clock
  --crctest=[type]      Test speed of checksum functions
  --cmdhelp=cmd         Print command help, "all" for all of them
  --enghelp=engine      Print ioengine help, or list available ioengines
  --enghelp=engine,cmd  Print help for an ioengine cmd
  --showcmd             Turn a job file into command line options
  --eta=when            When ETA estimate should be printed
                        May be "always", "never" or "auto"
  --eta-newline=t       Force a new line for every 't' period passed
  --status-interval=t   Force full status dump every 't' period passed
  --readonly            Turn on safety read-only checks, preventing writes
  --section=name        Only run specified section in job file, multiple sections can be specified
  --alloc-size=kb       Set smalloc pool to this size in kb (def 16384)
  --warnings-fatal      Fio parser warnings are fatal
  --max-jobs=nr         Maximum number of threads/processes to support
  --server=args         Start a backend fio server
  --daemonize=pidfile   Background fio server, write pid to file
  --client=hostname     Talk to remote backend(s) fio server at hostname
  --remote-config=file  Tell fio server to load this local job file
  --idle-prof=option    Report cpu idleness on a system or percpu basis
                        (option=system,percpu) or run unit work
                        calibration only (option=calibrate)
  --inflate-log=log     Inflate and output compressed log
  --trigger-file=file   Execute trigger cmd when file exists
  --trigger-timeout=t   Execute trigger at this time
  --trigger=cmd         Set this command as local trigger
  --trigger-remote=cmd  Set this command as remote trigger
  --aux-path=path       Use this path for fio state generated files

Fio was written by Jens Axboe <axboe@kernel.dk>
```

## EL8

```bash
# Download all RPMs
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-3.40-1.el8.src.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-debugsource-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-dev-dax-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-dev-dax-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-http-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-http-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-libaio-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-libaio-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-libpmem-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-libpmem-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-nbd-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-nbd-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rados-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rados-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rbd-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rbd-debuginfo-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rdma-3.40-1.el8.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el8/fio-engine-rdma-debuginfo-3.40-1.el8.x86_64.rpm

# Install all engines (excluding debug packages)
yum -y localinstall fio-3.40-1.el8.x86_64.rpm \
  fio-engine-dev-dax-3.40-1.el8.x86_64.rpm \
  fio-engine-http-3.40-1.el8.x86_64.rpm \
  fio-engine-libaio-3.40-1.el8.x86_64.rpm \
  fio-engine-libpmem-3.40-1.el8.x86_64.rpm \
  fio-engine-nbd-3.40-1.el8.x86_64.rpm \
  fio-engine-rados-3.40-1.el8.x86_64.rpm \
  fio-engine-rbd-3.40-1.el8.x86_64.rpm \
  fio-engine-rdma-3.40-1.el8.x86_64.rpm \
  --allowerasing
```

## EL9

```bash
# Download all RPMs
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-3.40-1.el9.src.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-debugsource-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-dev-dax-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-dev-dax-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-http-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-http-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-libaio-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-libaio-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-libpmem-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-libpmem-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-nbd-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-nbd-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rados-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rados-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rbd-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rbd-debuginfo-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rdma-3.40-1.el9.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el9/fio-engine-rdma-debuginfo-3.40-1.el9.x86_64.rpm

# Install all engines (excluding debug packages)
yum -y localinstall fio-3.40-1.el9.x86_64.rpm \
  fio-engine-dev-dax-3.40-1.el9.x86_64.rpm \
  fio-engine-http-3.40-1.el9.x86_64.rpm \
  fio-engine-libaio-3.40-1.el9.x86_64.rpm \
  fio-engine-libpmem-3.40-1.el9.x86_64.rpm \
  fio-engine-nbd-3.40-1.el9.x86_64.rpm \
  fio-engine-rados-3.40-1.el9.x86_64.rpm \
  fio-engine-rbd-3.40-1.el9.x86_64.rpm \
  fio-engine-rdma-3.40-1.el9.x86_64.rpm \
  --allowerasing
```

## EL10

```bash
# Download all RPMs
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-3.40-1.el10.src.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-debugsource-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-dev-dax-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-dev-dax-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-http-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-http-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-libaio-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-libaio-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-libpmem-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-libpmem-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-nbd-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-nbd-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rados-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rados-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rbd-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rbd-debuginfo-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rdma-3.40-1.el10.x86_64.rpm
wget -4 https://centminmod.com/centminmodparts/rpms/fio/el10/fio-engine-rdma-debuginfo-3.40-1.el10.x86_64.rpm

# Install all engines (excluding debug packages)
yum -y localinstall fio-3.40-1.el10.x86_64.rpm \
  fio-engine-dev-dax-3.40-1.el10.x86_64.rpm \
  fio-engine-http-3.40-1.el10.x86_64.rpm \
  fio-engine-libaio-3.40-1.el10.x86_64.rpm \
  fio-engine-libpmem-3.40-1.el10.x86_64.rpm \
  fio-engine-nbd-3.40-1.el10.x86_64.rpm \
  fio-engine-rados-3.40-1.el10.x86_64.rpm \
  fio-engine-rbd-3.40-1.el10.x86_64.rpm \
  fio-engine-rdma-3.40-1.el10.x86_64.rpm \
  --allowerasing
```