#!/bin/bash
#########################################################
# sysbench install and benchmark for centminmod.com
# https://github.com/akopytov/sysbench/releases
# # written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
VER='1.7'

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
# fileio fsync test duration
FILEIO_FSYNCTIME='30'

MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USESOCKET='y'
MYSQL_SOCKET='/var/lib/mysql/mysql.sock'
MYSQL_LOGIN='y'
MYSQL_USER='sbtest'
MYSQL_PASS='sbtestpass'
MYSQL_DBNAME='sbt'
MYSQL_ENGINE='InnoDB'
MYSQL_TIME='30'
# max cpu threads detected via nproc output
MYSQL_THREADS="$(nproc)"
MYSQL_TABLECOUNT='8'
MYSQL_OLTPTABLESIZE='150000'
MYSQL_SCALE='100'

COLLECT_MYSQLSTATS='y'
COLLECT_DISKSTATS='y'
COLLECT_PIDSTATS='y'

SYSBENCH_DIR='/home/sysbench'
SYSBENCH_FILEIODIR="${SYSBENCH_DIR}/fileio"
#########################################################
# functions
#########################################################
SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
#########################################################

if [ -f /usr/bin/apt ]; then
  MYSQL_SOCKET='/var/run/mysqld/mysqld.sock'
fi

if [ ! -d "$SYSBENCH_DIR" ]; then
  mkdir -p "${SYSBENCH_DIR}"
fi

if [ ! -d "${SYSBENCH_FILEIODIR}" ]; then
  mkdir -p "${SYSBENCH_FILEIODIR}"
fi

if [ ! -d "${SYSBENCH_DIR}/mysql" ]; then
  mkdir -p "${SYSBENCH_DIR}/mysql"
fi

if [ -f "${SCRIPT_DIR}/sysbench.ini" ]; then
  source "${SCRIPT_DIR}/sysbench.ini"
fi

if [[ "$MYSQL_LOGIN" = [yY] ]]; then
  MYSQL_LOGINOPT=" --mysql-user=${MYSQL_USER} --mysql-password=${MYSQL_PASS}"
else
  MYSQL_LOGINOPT=""
fi

if [[ "$MYSQL_USESOCKET" = [yY] ]]; then
  MYSQL_USESOCKETOPT=" --mysql-socket=${MYSQL_SOCKET}"
  MYSQLCLIENT_USESOCKETOPT="${MYSQL_SOCKET}"
else
  MYSQL_USESOCKETOPT=""
  MYSQLCLIENT_USESOCKETOPT=""
fi

if [ -f /usr/bin/sysbench ]; then
  SYSBENCH_GETVER=$(sysbench --version | awk '{print $2}' | cut -d . -f1,3 | sed -e 's|\.||g')
fi

tools_setup() {
  # wget -q -O /usr/local/bin/tlbstat https://github.com/brendangregg/pmc-cloud-tools/raw/master/tlbstat
  wget -q -O /usr/local/bin/pmcarch https://github.com/brendangregg/pmc-cloud-tools/raw/master/pmcarch
  wget -q -O /usr/local/bin/cpucache https://github.com/brendangregg/pmc-cloud-tools/raw/master/cpucache
  wget -q -O /usr/local/bin/syscount https://github.com/brendangregg/perf-tools/raw/master/syscount
  wget -q -O /usr/local/bin/iosnoop https://github.com/brendangregg/perf-tools/raw/master/iosnoop
  wget -q -O /usr/local/bin/funccount https://github.com/brendangregg/perf-tools/raw/master/kernel/funccount
  # chmod +x /usr/local/bin/tlbstat
  chmod +x /usr/local/bin/pmcarch
  chmod +x /usr/local/bin/cpucache
  chmod +x /usr/local/bin/syscount
  chmod +x /usr/local/bin/iosnoop
  chmod +x /usr/local/bin/funccount
}

get_mysqlstats(){
  mysqltag=$1
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} ext -i10 > "$SYSBENCH_DIR/mysqlstats-${mysqltag}.log" &
    getmysqlstats_pid=$!
  fi
}
get_diskstats(){
  disktag=$1
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    vmstat 1 > "$SYSBENCH_DIR/diskstats-${disktag}.log" &
    getdiskstats_pid=$!
  fi
}
get_pidstats(){
  pidstattag=$1
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    pidstat -durh 1 | egrep 'sysbench|mysqld|UID' > "$SYSBENCH_DIR/pidstat-${pidstattag}.log" &
    getpidstat_pid=$!
  fi
}

mysqlsettings() {
  echo
  echo "MySQL Buffers"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/buffer/ {print $2,$3}' | tr -s ' '| column -t
  echo
  echo "MySQL Limits"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/limit/ {print $2,$3}' | tr -s ' '| column -t
  echo
  echo "MySQL Maxes"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/max/ {print $2,$3}' | tr -s ' '| egrep -v 'limit|buffer|performance_schema'| column -t
  echo
  echo "MySQL Concurrency"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/concurr/ {print $2,$3}' | tr -s ' ' | egrep -v 'limit|buffer|performance_schema' | column -t  
  echo
  echo "MySQL Read/Write"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'reads|write' | grep -v thread | awk -F '|' '{print $2,$3}' | tr -s ' ' | egrep -v 'limit|buffer|performance_schema' | column -t  
  echo
  echo "MySQL Threads"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'thread' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo
  echo "MySQL Binlog"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'binlog|log_bin' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo
  echo "MySQL InnoDB"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'innodb' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo
}

baseinfo() {
  echo "-------------------------------------------"
  echo "System Information"
  echo "-------------------------------------------"
  echo

  uname -r
  echo

  if [ -f /etc/redhat-release ]; then
    cat /etc/redhat-release
  elif [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release
  fi
  echo
  
  if [ -f /etc/centminmod-release ]; then
  echo -n "Centmin Mod "
  cat /etc/centminmod-release 2>&1 >/dev/null
  echo
  fi
  
  if [ ! -f /proc/user_beancounters ]; then
    CPUFLAGS=$(cat /proc/cpuinfo | grep '^flags' | cut -d: -f2 | awk 'NR==1')
    lscpu
    echo
    echo "CPU Flags"
    echo "$CPUFLAGS"    
  else
    CPUNAME=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | tr -s " " | head -n 1)
    CPUCOUNT=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | wc -l)
    CPUFLAGS=$(cat /proc/cpuinfo | grep '^flags' | cut -d: -f2 | awk 'NR==1')
    echo "CPU: $CPUCOUNT x$CPUNAME"
    uname -m
    echo
    echo "CPU Flags"
    echo "$CPUFLAGS"
  fi
  echo

  if [ ! -f /proc/user_beancounters ]; then
  lscpu -e
  echo
  fi
  
  # cat /proc/cpuinfo
  # s
  
  free -ml
  echo
  
  df -h
  echo
}

sysbench_update() {
  echo
  if [ -d /etc/yum.repos.d ]; then
    echo "update sysbench from yum repo"
    if [ -f /etc/yum.repos.d/epel.repo ]; then
      echo "yum -y update sysbench --disablerepo=epel"
      yum -y update sysbench --disablerepo=epel
    else
      echo "yum -y update sysbench"
      yum -y update sysbench
    fi
  elif [ -f /usr/bin/apt ]; then
   echo "update sysbench from apt"
   sudo apt -y install sysbench
  fi
  echo
}

sysbench_install() {
  if [[ ! -f /usr/bin/sysbench || "$SYSBENCH_GETVER" -lt '100' ]]; then
    if [ -d /etc/yum.repos.d ]; then
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
    elif [ -f /usr/bin/apt ]; then
      echo
      echo "install sysbench from apt"
      # ensure sysbench version is latest
      if [[ -f /usr/bin/sysbench  && "$SYSBENCH_GETVER" -lt '100' ]]; then
        apt-get -y -q remove sysbench
      fi
      curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
      echo "sudo apt -y install sysbench"
      sudo apt -y install sysbench
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
  check_fsync=$1
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

  if [[ "$check_fsync" = 'fsync' ]]; then
    # sequential read
    FILEIO_SEQRD='n'
    # sequential write
    FILEIO_SEQWR='n'
    # sequent rewrite
    FILEIO_SEQREWR='n'
    # random read
    FILEIO_RNDRD='n'
    # random write
    FILEIO_RNDWR='n'
    # random read/write
    FILEIO_RNDRW='n'
    echo
    echo "sysbench fileio fsync prepare"
    echo "sysbench fileio --time=$FILEIO_FSYNCTIME --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --file-fsync-freq=0 --file-fsync-end=0 --threads=1 --percentile=99 prepare"
      sysbench fileio --time=$FILEIO_FSYNCTIME --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --file-fsync-freq=0 --file-fsync-end=0 --threads=1 --percentile=99 prepare >/dev/null 2>&1
    echo
    echo "sysbench fileio --threads=1 --time=$FILEIO_FSYNCTIME --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --file-fsync-freq=0 --file-fsync-end=0 --percentile=99 run" | tee "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1.log"
    if [ -f /usr/lib64/libjemalloc.so.1 ]; then
      LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench fileio --threads=1 --time=$FILEIO_FSYNCTIME --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --file-fsync-freq=0 --file-fsync-end=0 --percentile=99 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-raw.log"
    else
      sysbench fileio --threads=1 --time=$FILEIO_FSYNCTIME --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 --file-fsync-all=on --file-test-mode=rndwr --file-fsync-freq=0 --file-fsync-end=0 --percentile=99 run 2>&1 > "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-raw.log"
    fi
    echo "raw log saved: $SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-raw.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-raw.log" | egrep 'sysbench |Number of threads:|Block size|ratio |mode|Doing |reads/s:|writes/s:|fsyncs/s:|read, | written,|total time:|min:|avg:|max:|99th percentile:' | sed -e 's|Number of threads|threads|' -e 's| size|-size|' -e 's|total time:|time:|' -e 's|, MiB/s|-MiB/s|g' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' '| tee -a "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1.log"
    echo
    echo -n "| fileio "; cat "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-markdown.log"
    echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-markdown.log"
    echo -n "| "; cat "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1.log" | grep -v 'ratio' | sed -e 's|Using ||' -e 's| mode||' -e 's|Doing ||' -e 's| test||' | awk '{print $1,$2}' | xargs | awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-markdown.log"
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-fsync-threads-1-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'
    echo
    echo
    echo "sysbench fileio cleanup"
    echo "sysbench fileio --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 cleanup"
    sysbench fileio --file-num=1 --file-extra-flags= --file-total-size=4096 --file-block-size=4096 cleanup >/dev/null 2>&1
  fi
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

  if [[ ! "$check_fsync" ]]; then
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
  fi
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  get_mysqlstats mysqloltp-legacy-read-write
  get_diskstats mysqloltp-legacy-read-write
  get_pidstats mysqloltp-legacy-read-write

  echo
  echo "sysbench mysql benchmark:"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-readonly.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list-readonly.log"

  get_mysqlstats mysqloltp-legacy-read-only
  get_diskstats mysqloltp-legacy-read-only
  get_pidstats mysqloltp-legacy-read-only

  echo
  echo "sysbench mysql read only benchmark:"
  echo "sysbench oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --oltp-read-only=on --oltp-skip-trx=on --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-readonly.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
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

sysbench_mysqlinsert() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-insert.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-insert.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-insert.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list-insert.log"

  get_mysqlstats mysqloltp-legacy-insert
  get_diskstats mysqloltp-legacy-insert
  get_pidstats mysqloltp-legacy-insert

  echo
  echo "sysbench mysql insert benchmark:"
  echo "sysbench insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-insert.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-insert.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-insert.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
  echo
  echo "sysbench mysql insert summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-insert.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-insert.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-insert.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-insert.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-insert.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | sed -e 's|/usr/share/sysbench/tests/include/oltp_legacy/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-insert.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-insert.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/insert.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-insert.log"
  fi
}

sysbench_mysqlupdateindex() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updateindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updateindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updateindex.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list-insert.log"

  get_mysqlstats mysqloltp-legacy-update-index
  get_diskstats mysqloltp-legacy-update-index
  get_pidstats mysqloltp-legacy-update-index

  echo
  echo "sysbench mysql update index benchmark:"
  echo "sysbench update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updateindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updateindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updateindex.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
  echo
  echo "sysbench mysql update index summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updateindex.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updateindex.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updateindex.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updateindex.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updateindex.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | sed -e 's|/usr/share/sysbench/tests/include/oltp_legacy/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updateindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updateindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updateindex.log"
  fi
}

sysbench_mysqlupdatenonindex() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updatenonindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updatenonindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-updatenonindex.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list-insert.log"

  get_mysqlstats mysqloltp-legacy-update-nonindex
  get_diskstats mysqloltp-legacy-update-nonindex
  get_pidstats mysqloltp-legacy-update-nonindex

  echo
  echo "sysbench mysql update index benchmark:"
  echo "sysbench update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updatenonindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updatenonindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updatenonindex.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
  echo
  echo "sysbench mysql update index summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-updatenonindex.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updatenonindex.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updatenonindex.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updatenonindex.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-updatenonindex.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-corrected-insert.log" | sed -e 's|/usr/share/sysbench/tests/include/oltp_legacy/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-markdown-insert.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updatenonindex.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updatenonindex.log"
  else
    sysbench /usr/share/sysbench/tests/include/oltp_legacy/update_non_index.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-table-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --oltp-table-size=${MYSQL_OLTPTABLESIZE} --oltp-tables-count=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-updatenonindex.log"
  fi
}
#########################################################
# new sysbench 1.0 lua scrips

sysbench_mysqloltp_new() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  get_mysqlstats mysqloltp-new-read-write
  get_diskstats mysqloltp-new-read-write
  get_pidstats mysqloltp-new-read-write

  echo
  echo "sysbench mysql OLTP new benchmark:"
  echo "sysbench oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
  echo
  echo "sysbench mysql OLTP new summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-write-new.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | sed -e 's|/usr/share/sysbench/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-write-new.log"
  fi
}

sysbench_mysqlro_new() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  get_mysqlstats mysqloltp-new-read-only
  get_diskstats mysqloltp-new-read-only
  get_pidstats mysqloltp-new-read-only

  echo
  echo "sysbench mysql OLTP read only new benchmark:"
  echo "sysbench oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e
  
  echo
  echo "sysbench mysql OLTP read only new summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-read-only-new.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-only-new.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-only-new.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-only-new.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-only-new.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | sed -e 's|/usr/share/sysbench/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-read-only-new.log"
  fi
}

sysbench_mysqlwo_new() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  get_mysqlstats mysqloltp-new-write-only
  get_diskstats mysqloltp-new-write-only
  get_pidstats mysqloltp-new-write-only

  echo
  echo "sysbench mysql OLTP write only new benchmark:"
  echo "sysbench oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e

  echo
  echo "sysbench mysql OLTP write only new summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-write-only-new.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-write-only-new.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-write-only-new.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-write-only-new.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-write-only-new.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | sed -e 's|/usr/share/sysbench/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  else
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-write-only-new.log"
  fi
}

sysbench_mysqlpointselect_new() {
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

  mysqlsettings
  echo
  echo "sysbench prepare database: $MYSQL_DBNAME"
  echo "sysbench oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare" | tee "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  else
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql prepare | tee -a "$SYSBENCH_DIR/sysbench-mysql-prepare-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  fi

  echo
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} flush-tables
  sleep 3
  mysql -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} -t -e "SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', CONCAT(ROUND(table_rows,2),' Rows') AS 'Number of Rows',ENGINE AS 'Storage Engine',CONCAT(ROUND(data_length/(1024*1024),2),'MB') AS 'Data Size',
CONCAT(ROUND(index_length/(1024*1024),2),'MB') AS 'Index Size' ,CONCAT(ROUND((data_length+index_length)/(1024*1024),2),'MB') AS'Total', ROW_FORMAT, TABLE_COLLATION FROM information_schema.TABLES WHERE table_schema LIKE '$MYSQL_DBNAME';" | tee "$SYSBENCH_DIR/sysbench-mysql-table-list.log"

  get_mysqlstats mysqloltp-new-point-select
  get_diskstats mysqloltp-new-point-select
  get_pidstats mysqloltp-new-point-select

  echo
  echo "sysbench mysql OLTP POINT SELECT new benchmark:"
  echo "sysbench oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run" | tee "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  else
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql run | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  fi

  # set +e
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    kill $getmysqlstats_pid
    wait $getmysqlstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    kill $getdiskstats_pid
    wait $getdiskstats_pid 2>/dev/null
  fi
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    kill $getpidstat_pid
    wait $getpidstat_pid 2>/dev/null
  fi
  # set -e

  echo
  echo "sysbench mysql OLTP POINT SELECT new summary:"
  cat "$SYSBENCH_DIR/sysbench-mysql-run-threads-${MYSQL_THREADS}-oltp-point-select-new.log" | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' > "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-point-select-new.log"

  trans_persec=$(awk '/transactions:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-point-select-new.log" | sed -e 's|(||')
  queries_persec=$(awk '/queries:/ {print $3}' "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-point-select-new.log" | sed -e 's|(||')

  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-point-select-new.log" | sed -e "s|transactions: .*|transactions\/s: $trans_persec|" -e "s|queries: .*|queries\/s: $queries_persec|" | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log"

  echo
  echo -n "| mysql "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | awk '{print $1,$2}' | xargs | awk '{ for (i=1;i<=NF;i+=2) print $i" |" }' | xargs | tee "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"
  echo -n "| "; cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-corrected.log" | sed -e 's|/usr/share/sysbench/||' | awk '{print $1,$2}' | xargs |  awk '{for (i=2; i<=NF; i+=2)print $i" |" }' | xargs | tee -a "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log"

  echo
  cat "$SYSBENCH_DIR/sysbench-mysql-run-summary-threads-${MYSQL_THREADS}-oltp-read-write-new-markdown.log" | grep -v '\-\-\-' | sed -e 's| \| |,|g' -e 's|\:||g' -e 's|\|||'

  echo
  echo "sysbench mysql cleanup database: $MYSQL_DBNAME"
  echo "sysbench oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup" | tee "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  if [ -f /usr/lib64/libjemalloc.so.1 ]; then
    LD_PRELOAD=/usr/lib64/libjemalloc.so.1 sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
  else
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT} --mysql-db=${MYSQL_DBNAME} --mysql-storage-engine=${MYSQL_ENGINE} --time=${MYSQL_TIME} --threads=${MYSQL_THREADS} --report-interval=1 --rand-type=uniform --rand-seed=1 --table-size=${MYSQL_OLTPTABLESIZE} --tables=${MYSQL_TABLECOUNT} --db-driver=mysql cleanup | tee -a "$SYSBENCH_DIR/sysbench-mysql-cleanup-threads-${MYSQL_THREADS}-oltp-point-select-new.log"
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
    baseinfo
    sysbench_cpu
    ;;
  mem )
    baseinfo
    sysbench_mem
    ;;
  file )
    sysbench_fileio
    ;;
  file-fsync )
    sysbench_fileio fsync
    ;;
  mysql )
    sysbench_mysqloltp
    ;;
  mysqlro )
    sysbench_mysqlro
    ;;
  mysqlinsert )
    sysbench_mysqlinsert
    ;;
  mysqlupdateindex )
    sysbench_mysqlupdateindex
    ;;
  mysqlupdatenonindex )
    sysbench_mysqlupdatenonindex
    ;;
  mysqloltpnew )
    sysbench_mysqloltp_new
    ;;
  mysqlreadonly-new )
    sysbench_mysqlro_new
    ;;
  mysqlwriteonly-new )
    sysbench_mysqlwo_new
    ;;
  mysqlpointselect-new )
    sysbench_mysqlpointselect_new
    ;;
  all )
    baseinfo
    sysbench_cpu
    sysbench_mem
    sysbench_fileio
    sysbench_mysqloltp
    sysbench_mysqlro
    sysbench_mysqlupdateindex
    sysbench_mysqlupdatenonindex
    sysbench_mysqloltp_new
    sysbench_mysqlro_new
    sysbench_mysqlwo_new
    sysbench_mysqlpointselect_new
    echo
    echo "ls -lsh $SYSBENCH_DIR"
    ls -lsh $SYSBENCH_DIR
    echo
    ;;
  * )
    echo
    echo "Usage:"
    echo "$0 install"
    echo "$0 update"
    echo "$0 cpu"
    echo "$0 mem"
    echo "$0 file"
    echo "$0 file-fsync"
    echo "$0 mysql"
    echo "$0 mysqlro"
    echo "$0 mysqlinsert"
    echo "$0 mysqlupdateindex"
    echo "$0 mysqlupdatenonindex"
    echo "$0 mysqloltpnew"
    echo "$0 mysqlreadonly-new"
    echo "$0 mysqlwriteonly-new"
    echo "$0 mysqlpointselect-new"
    echo "$0 all"
    echo
    ;;
esac
exit
