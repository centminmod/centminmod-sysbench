#!/bin/bash
#########################################################
# sysbench install and benchmark for centminmod.com
# https://github.com/akopytov/sysbench/releases
# # written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
VER='0.1'

CPU_MAXPRIME='20000'
# 1K
MEM_BLOCKSIZE='1'
# gigabyte = G
MEM_TOTALSIZE='1'
FILEIO_BLOCKSIZE='4096'
FILEIO_TIME='10'

SYSBENCH_DIR='/home/sysbench'
#########################################################
# functions
#############

if [ ! -d "$SYSBENCH_DIR" ]; then
  mkdir -p /home/sysbench/fileio
fi

if [ -f /usr/bin/sysbench ]; then
  SYSBENCH_GETVER=$(sysbench --version | awk '{print $2}' | cut -d . -f1,3 | sed -e 's|\.||g')
fi

sysbench_install() {
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    echo
    echo "install sysbench from yum repo"
    # ensure sysbench version is latest
    if [[ -f /usr/bin/sysbench  && "$SYSBENCH_GETVER" -lt '100' ]]; then
      yum -y -q remove sysbench
    fi
    if [[ ! "$(grep sysbench /etc/yum.repos.d/epel.repo)" ]]; then
      excludevalue=$(grep '^exclude=' /etc/yum.repos.d/epel.repo | head -n1)
      sed -i "s/exclude=.*/${excludevalue} sysbench/" /etc/yum.repos.d/epel.repo
    fi
    curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | bash
    if [ -f /etc/yum.repos.d/epel.repo ]; then
      yum -y install sysbench --disablerepo=epel
    else
      yum -y install sysbench
    fi
    echo
  else
    echo
    echo "sysbench already installed"
    echo
  fi
}

sysbench_cpu() {
  echo
  cd "$SYSBENCH_DIR"
  echo "threads: 1";
  echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run";
  sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ';

  echo
  echo "threads: $(nproc)";
  echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run";
  sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ';
}

sysbench_mem() {
  echo
  cd "$SYSBENCH_DIR"
  echo "threads: 1";
  echo "sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run";
  sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ';

  echo
  echo "threads: $(nproc)";
  echo "sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run";
  sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ';
}

sysbench_fileio() {
  tt_ram=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  tt_swap=$(awk '/SwapTotal:/ {print $2}' /proc/meminfo)
  fileio_filesize=$(((($tt_ram+$tt_swap)*11)/10))
  cd "$SYSBENCH_DIR/fileio"
  echo
  echo "sysbench fileio prepare"
  echo "sysbench fileio --file-total-size=$fileio_filesize prepare"
  sysbench fileio --file-total-size=$fileio_filesize prepare >/dev/null 2>&1
  echo

  echo "threads: 1";
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '

  echo
  echo "threads: $(nproc)";
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '
  echo
  echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run"
  sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '

  echo
  echo "sysbench fileio cleanup"
  echo "sysbench fileio --file-total-size=$fileio_filesize cleanup"
  sysbench fileio --file-total-size=$fileio_filesize cleanup >/dev/null 2>&1
}

#########################################################
case "$1" in
  install )
    sysbench_install
    ;;
  cpu )
    sysbench_cpu
    ;;
  mem )
    sysbench_mem
    ;;
  file )
    sysbench_fileio
    ;;
  mysql )
    ;;
  * )
    echo
    echo "Usage:"
    echo "$0 {install|cpu|mem|file|mysql}"
    echo
    ;;
esac
exit
