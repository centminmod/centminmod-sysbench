#!/bin/bash
#########################################################
# sysbench install and benchmark for centminmod.com
# https://github.com/akopytov/sysbench/releases
# # written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
VER='0.3'

# default tests single thread + max cpu threads if set to
# TEST_SINGLETHREAD='n'
# if set to TEST_SINGLETHREAD='y' only test single thread
# skip max cpu threads tests
TEST_SINGLETHREAD='n'

CPU_MAXPRIME='20000'
# 1K
MEM_BLOCKSIZE='1'
# gigabyte = G
MEM_TOTALSIZE='1'

FILEIO_BLOCKSIZE='4096'
# --file-io-mode= choices sync, async, fastmmap, slowmmap
FILEIO_MODE='sync'
FILEIO_TIME='10'
# sequential read
FILEIO_SEQRD='y'
# sequential write
FILEIO_SEQWR='y'
# sequent rewrite
FILEIO_SEQREWR='y'
# random read
FILEIO_RNDRD='y'
# random write
FILEIO_RNDWR='y'
# random read/write
FILEIO_RNDRW='y'

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

sysbench_update() {
  echo
  echo "update sysbench from yum repo"
  if [ -f /etc/yum.repos.d/epel.repo ]; then
    echo "yum -y update sysbench --disablerepo=epel"
    yum -y update sysbench --disablerepo=epel
  else
    echo "yum -y update sysbench"
    yum -y update sysbench
  fi
  echo
}

sysbench_install() {
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    echo
    echo "install sysbench from yum repo"
    # ensure sysbench version is latest
    if [[ -f /usr/bin/sysbench  && "$SYSBENCH_GETVER" -lt '100' ]]; then
      yum -y -q remove sysbench
    fi
    if [[ -f /etc/yum.repos.d/epel.repo && ! "$(grep sysbench /etc/yum.repos.d/epel.repo)" ]]; then
      excludevalue=$(grep '^exclude=' /etc/yum.repos.d/epel.repo | head -n1)
      sed -i "s/exclude=.*/${excludevalue} sysbench/" /etc/yum.repos.d/epel.repo
    fi
    curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | bash
    if [ -f /etc/yum.repos.d/epel.repo ]; then
      echo "yum -y install sysbench --disablerepo=epel"
      yum -y install sysbench --disablerepo=epel
    else
      echo "yum -y install sysbench"
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
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    sysbench_install
  fi
  echo
  cd "$SYSBENCH_DIR"
  # echo "threads: 1";
  echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run" | tee "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
    echo
    echo -n "| cpu "; cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" | grep -v prime | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-cpu-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" | grep -v prime | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  if [[ "$TEST_SINGLETHREAD" != [yY] ]]; then
    echo
    # echo "threads: $(nproc)";
    echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run" | tee "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log"
    sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log"
      echo
      echo -n "| cpu "; cat "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log" | grep -v prime | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log" | grep -v prime | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
  fi
}

sysbench_mem() {
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    sysbench_install
  fi
  echo
  cd "$SYSBENCH_DIR"
  # echo "threads: 1";
  echo "sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run" | tee "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  echo
  echo -n "| memory "; cat "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | egrep -v 'scope:' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mem-threads-1-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | egrep -v 'scope:' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | sed -e 's|(||' | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1-markdown.log"
  echo
  cat "$SYSBENCH_DIR/sysbench-mem-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  if [[ "$TEST_SINGLETHREAD" != [yY] ]]; then
    echo
    # echo "threads: $(nproc)";
    echo "sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run" | tee "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log"
    sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log"
    echo
    echo -n "| memory "; cat "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log" | egrep -v 'scope:' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc)-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc)-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log" | egrep -v 'scope:' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs| sed -e 's|(||' | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc)-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
  fi
}

sysbench_fileio() {
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    sysbench_install
  fi
  tt_ram=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  tt_swap=$(awk '/SwapTotal:/ {print $2}' /proc/meminfo)
  fileio_filesize=$(((($tt_ram+$tt_swap)*11)/10))
  cd "$SYSBENCH_DIR/fileio"
  echo
  echo "sysbench fileio prepare"
  echo "sysbench fileio --file-total-size=$fileio_filesize prepare"
  sysbench fileio --file-total-size=$fileio_filesize prepare >/dev/null 2>&1
  echo

  # echo "threads: 1";
  if [[ "$FILEIO_SEQRD" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_SEQWR" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_SEQREWR" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDRD" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDWR" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDRW" = [yY] ]]; then
    echo "sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log"
    sysbench fileio --threads=1 --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
  fi
  if [[ "$TEST_SINGLETHREAD" != [yY] ]]; then
    echo
    # echo "threads: $(nproc)";
    if [[ "$FILEIO_SEQRD" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_SEQWR" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_SEQREWR" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDRD" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDWR" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDRW" = [yY] ]]; then
      echo "sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log"
      sysbench fileio --threads=$(nproc) --file-total-size=$fileio_filesize --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run| egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    fi
  fi

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
  update )
    sysbench_update
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
    echo "$0 {install|update|cpu|mem|file|mysql}"
    echo
    ;;
esac
exit
