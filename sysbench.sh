#!/bin/bash
#########################################################
# sysbench install and benchmark for centminmod.com
# https://github.com/akopytov/sysbench/releases
# # written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
VER='0.7'

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

FILEIO_SLEEP='5'
# in megabytes
FILEIO_FILESIZE='2048'
# number of files to create default = 128
FILEIO_FILENUM='128'
# sync, dsync or direct
FILEIO_EXTRAFLAGS='direct'
FILEIO_BLOCKSIZE='4096'
# --file-io-mode= choices sync, async, fastmmap, slowmmap
FILEIO_MODE='sync'
FILEIO_TIME='10'
# sequential read
FILEIO_SEQRD='y'
# sequential write
FILEIO_SEQWR='y'
# sequent rewrite
FILEIO_SEQREWR='n'
# random read
FILEIO_RNDRD='y'
# random write
FILEIO_RNDWR='y'
# random read/write
FILEIO_RNDRW='n'

MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USESOCKET='y'
MYSQL_SOCKET='/var/lib/mysql/mysql.sock'
MYSQL_LOGIN='y'
MYSQL_USER='sbtest'
MYSQL_PASS='sbtestpass'
MYSQL_DBNAME='sbt'
MYSQL_ENGINE='InnoDB'
MYSQL_TIME='20'
# max cpu threads detected via nproc output
MYSQL_THREADS="$(nproc)"
MYSQL_TABLECOUNT='8'
MYSQL_OLTPTABLESIZE='150000'
MYSQL_SCALE='100'


SYSBENCH_DIR='/home/sysbench'
SYSBENCH_FILEIODIR="${SYSBENCH_DIR}/fileio"
#########################################################
# functions
#############

if [ ! -d "$SYSBENCH_DIR" ]; then
  mkdir -p "${SYSBENCH_DIR}"
fi

if [ ! -d "${SYSBENCH_FILEIODIR}" ]; then
  mkdir -p "${SYSBENCH_FILEIODIR}"
fi

if [ ! -d "${SYSBENCH_DIR}/mysql" ]; then
  mkdir -p "${SYSBENCH_DIR}/mysql"
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
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  else
      sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  fi
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
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log"
    else
      sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=$(nproc) run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-$(nproc).log"
    fi
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
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  else
    sysbench memory --threads=1 --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  fi
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
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log"
    else
      sysbench memory --threads=$(nproc) --memory-block-size=${MEM_BLOCKSIZE}K --memory-scope=global --memory-total-size=${MEM_TOTALSIZE}G --memory-oper=read run | egrep 'sysbench |Number of threads:|block size:|total size:|operation:|scope:|Total operations:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|Total operations:|total-ops:|' -e 's|total time:|time:|' -e 's|1024.00 MiB||' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-mem-threads-$(nproc).log"
    fi
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
  # 5% more
  #fileio_getfilesize=$(((($tt_ram)*105)/100))
  fileio_getfilesize=$(((($tt_ram)*10)/100))
  #fileio_filesize=$(($fileio_getfilesize/1024))
  fileio_filesize=${FILEIO_FILESIZE}
  checkdisk_space=$(df -mP /home | tail -1 | awk '{print $4}')
  if [[ "$fileio_filesize" -ge "$checkdisk_space" ]]; then
    echo
    echo "warning: fileio required disk space $fileio_filesize MB"
    echo "         is larger than /home disk free space $checkdisk_space"
    echo "         aborting test..."
    echo
    exit
  fi
  cd "${SYSBENCH_FILEIODIR}"

  # echo "threads: 1";
  if [[ "$FILEIO_SEQRD" = [yY] ]]; then
    # sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrd prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrd prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_SEQWR" = [yY] ]]; then
    sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
    sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqwr prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqwr prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_SEQREWR" = [yY] ]]; then
    sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
    sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrewr prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrewr prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDRD" = [yY] ]]; then
    sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
    sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrd prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrd prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDWR" = [yY] ]]; then
    sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
    sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndwr prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndwr prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
  fi
  if [[ "$FILEIO_RNDRW" = [yY] ]]; then
    sleep $FILEIO_SLEEP
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
    sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
    echo
    echo "sysbench fileio prepare"
    echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrw prepare"
    sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrw prepare >/dev/null 2>&1
    echo

    echo "sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log"  
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-1.log"
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
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrd prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrd prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log"    
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrd-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_SEQWR" = [yY] ]]; then
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqwr prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqwr prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log"     
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqwr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_SEQREWR" = [yY] ]]; then
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrewr prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=seqrewr prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log"     
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=seqrewr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-seqrewr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDRD" = [yY] ]]; then
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrd prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrd prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log" 
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrd --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndrd-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDWR" = [yY] ]]; then
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndwr prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndwr prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log"
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndwr --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log"
      echo
      echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc).log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndwr-threads-$(nproc)-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
      echo
    fi
    if [[ "$FILEIO_RNDRW" = [yY] ]]; then
      sleep $FILEIO_SLEEP
      sleep $FILEIO_SLEEP
      echo
      echo "sysbench fileio cleanup"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
      sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1
      echo
      echo "sysbench fileio prepare"
      echo "sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrw prepare"
      sysbench fileio --file-total-size=${fileio_filesize}M --file-test-mode=rndrw prepare >/dev/null 2>&1
      echo

      echo "sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run" | tee "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log"
      if [ -f /usr/lib64/libjemalloc.so.1 ]; then
        LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-raw.log"
      else
        sysbench fileio --threads=$(nproc) --file-num=${FILEIO_FILENUM} --file-total-size=${fileio_filesize}M --file-block-size=${FILEIO_BLOCKSIZE} --file-io-mode=${FILEIO_MODE} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-test-mode=rndrw --time=${FILEIO_TIME} --events=0 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-raw.log"
      fi
      echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-raw.log"
      echo
      cat "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc)-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-rndrw-threads-$(nproc).log"
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
  echo "sysbench fileio --file-total-size=${fileio_filesize}M cleanup"
  sysbench fileio --file-total-size=${fileio_filesize}M cleanup >/dev/null 2>&1

  echo
  echo "| fileio sysbench | sysbench | threads: | Block-size | synchronous | sequential | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'seq' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done

  echo 
  echo "| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  ls -rt /home/sysbench/  | grep 'sysbench-fileio' | grep 'markdown' | grep 'rnd' | while read f; do echo -n '|'; grep 'fileio' /home/sysbench/$f; done
  echo
}

sysbench_mysqltpcc() {
  cd "$SYSBENCH_DIR/mysql"
  echo
  echo "download sysbench tpcc scripts"
  wget -4 -cnv https://github.com/Percona-Lab/sysbench-tpcc/raw/master/tpcc_check.lua -O tpcc_check.lua && chmod +x tpcc_check.lua
  wget -4 -cnv https://github.com/Percona-Lab/sysbench-tpcc/raw/master/tpcc_common.lua -O tpcc_common.lua && chmod +x tpcc_common.lua
  wget -4 -cnv https://github.com/Percona-Lab/sysbench-tpcc/raw/master/tpcc_run.lua -O tpcc_run.lua && chmod +x tpcc_run.lua
  wget -4 -cnv https://github.com/Percona-Lab/sysbench-tpcc/raw/master/tpcc.lua -O tpcc.lua && chmod +x tpcc.lua

  echo
  echo "setup $MYSQL_DBNAME database & user"
  echo y | mysqladmin drop $MYSQL_DBNAME
  echo "mysqladmin create $MYSQL_DBNAME"
  mysqladmin create $MYSQL_DBNAME
  echo
  mysql -e "show grants for '$MYSQL_USER'@'$MYSQL_HOST';" >/dev/null 2>&1
  CHECKUSER=$?
  if [[ "$CHECKUSER" -ne '0' ]]; then
    echo "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASS'; GRANT ALL PRIVILEGES ON \`$MYSQL_DBNAME\`.* TO '$MYSQL_USER'@'$MYSQL_HOST'; flush privileges; show grants for '$MYSQL_USER'@'$MYSQL_HOST';" | mysql
  fi

  if [[ "$MYSQL_LOGIN" = [yY] ]]; then
    MYSQL_LOGINOPT=" --mysql-user=${MYSQL_USER} --mysql-password=${MYSQL_PASS}"
  else
    MYSQL_LOGINOPT=""
  fi

  if [[ "$MYSQL_USESOCKET" = [yY] ]]; then
    MYSQL_USESOCKETOPT="  --mysql-socket=${MYSQL_SOCKET}"
  else
    MYSQL_USESOCKETOPT=""
  fi

  echo
  echo "./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql prepare"
  ./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql prepare

  echo
  mysql -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';"

  echo
  echo "./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql run"
  ./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql run

  echo
  echo "./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql cleanup"
  ./tpcc.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --tables=${MYSQL_TABLECOUNT} --scale=${MYSQL_SCALE} --db-driver=mysql cleanup
}

sysbench_mysqloltp() {
  cd "$SYSBENCH_DIR/mysql"

  echo
  echo "setup $MYSQL_DBNAME database & user"
  if [ -d "/var/lib/mysql/$MYSQL_DBNAME" ]; then
    echo y | mysqladmin drop $MYSQL_DBNAME >/dev/null 2>&1
  fi
  echo "mysqladmin create database: $MYSQL_DBNAME"
  mysqladmin create $MYSQL_DBNAME
  mysql -e "show grants for '$MYSQL_USER'@'$MYSQL_HOST';" >/dev/null 2>&1
  CHECKUSER=$?
  if [[ "$CHECKUSER" -ne '0' ]]; then
    echo "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASS'; GRANT ALL PRIVILEGES ON \`$MYSQL_DBNAME\`.* TO '$MYSQL_USER'@'$MYSQL_HOST'; flush privileges; show grants for '$MYSQL_USER'@'$MYSQL_HOST';" | mysql
  fi

  if [[ "$MYSQL_LOGIN" = [yY] ]]; then
    MYSQL_LOGINOPT=" --mysql-user=${MYSQL_USER} --mysql-password=${MYSQL_PASS}"
  else
    MYSQL_LOGINOPT=""
  fi

  if [[ "$MYSQL_USESOCKET" = [yY] ]]; then
    MYSQL_USESOCKETOPT="  --mysql-socket=${MYSQL_SOCKET}"
  else
    MYSQL_USESOCKETOPT=""
  fi

  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  fi

  echo
  sleep 8
  mysql -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  echo
  echo "sysbench mysql benchmark:"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  fi

  echo
  echo "sysbench mysql summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected.log" | sed -e 's|/usr/share/sysbench/tests/include/oltp_legacy/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}.log"
  fi
}

sysbench_mysqlro() {
  cd "$SYSBENCH_DIR/mysql"

  echo
  echo "setup $MYSQL_DBNAME database & user"
  if [ -d "/var/lib/mysql/$MYSQL_DBNAME" ]; then
    echo y | mysqladmin drop $MYSQL_DBNAME >/dev/null 2>&1
  fi
  echo "mysqladmin create database: $MYSQL_DBNAME"
  mysqladmin create $MYSQL_DBNAME
  mysql -e "show grants for '$MYSQL_USER'@'$MYSQL_HOST';" >/dev/null 2>&1
  CHECKUSER=$?
  if [[ "$CHECKUSER" -ne '0' ]]; then
    echo "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASS'; GRANT ALL PRIVILEGES ON \`$MYSQL_DBNAME\`.* TO '$MYSQL_USER'@'$MYSQL_HOST'; flush privileges; show grants for '$MYSQL_USER'@'$MYSQL_HOST';" | mysql
  fi

  if [[ "$MYSQL_LOGIN" = [yY] ]]; then
    MYSQL_LOGINOPT=" --mysql-user=${MYSQL_USER} --mysql-password=${MYSQL_PASS}"
  else
    MYSQL_LOGINOPT=""
  fi

  if [[ "$MYSQL_USESOCKET" = [yY] ]]; then
    MYSQL_USESOCKETOPT="  --mysql-socket=${MYSQL_SOCKET}"
  else
    MYSQL_USESOCKETOPT=""
  fi

  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  fi

  echo
  sleep 8
  mysql -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list-readonly.log"

  echo
  echo "sysbench mysql read only benchmark:"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  fi

  echo
  echo "sysbench mysql read only summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-readonly.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-readonly.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-readonly.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-readonly.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-readonly.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-readonly.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-readonly.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-readonly.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-readonly.log" | sed -e 's|/usr/share/sysbench/tests/include/oltp_legacy/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-readonly.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-readonly.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-readonly.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-readonly.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-readonly.log"
  fi
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
    sysbench_mysqloltp
    ;;
  mysqlro )
    sysbench_mysqlro
    ;;
  * )
    echo
    echo "Usage:"
    echo "$0 {install|update|cpu|mem|file|mysql|mysqlro}"
    echo
    ;;
esac
exit
