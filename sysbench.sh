#!/bin/bash
#########################################################
# sysbench install and benchmark for centminmod.com
# https://github.com/akopytov/sysbench/releases
# written by George Liu (eva2000) https://centminmod.com
# Updated to support AlmaLinux 8, 9, 10 with HTML export
#########################################################
# Variables
#############
DT=$(date +"%d%m%y-%H%M%S")  # Timestamp for logs and reports
VER='2.9'

# Test single-threaded by default; set to 'y' to skip multi-thread tests
TEST_SINGLETHREAD='n'

# CPU test parameters
CPU_MAXPRIME='10000'

# Memory test parameters
MEM_BLOCKSIZE='1'  # 1KB block size
MEM_TOTALSIZE='1'  # 1GB total size

# File I/O test parameters
FILEIO_SLEEP='5'  # Sleep between tests (seconds)
FILEIO_FILESIZE='2048'  # File size in MB (~2GB)
FILEIO_FILENUM='128'  # Number of files
FILEIO_EXTRAFLAGS='direct'  # I/O flags: sync, dsync, or direct
FILEIO_BLOCKSIZE='4096'  # Block size in bytes
FILEIO_MODE='sync'  # I/O mode: sync, async, fastmmap, slowmmap
FILEIO_TIME='10'  # Test duration (seconds)
FILEIO_SEQRD='y'  # Sequential read test
FILEIO_SEQWR='y'  # Sequential write test
FILEIO_SEQREWR='n'  # Sequential rewrite test
FILEIO_RNDRD='y'  # Random read test
FILEIO_RNDWR='y'  # Random write test
FILEIO_RNDRW='n'  # Random read/write test
FILEIO_FSYNCTIME='30'  # Fsync test duration (seconds)

# MySQL test parameters
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USESOCKET='y'  # Use socket if 'y'
MYSQL_SOCKET='/var/lib/mysql/mysql.sock'  # Default socket path
MYSQL_LOGIN='y'  # Enable login if 'y'
MYSQL_USER='sbtest'  # Benchmark user
MYSQL_PASS='sbtestpass'  # Benchmark password
MYSQL_DBNAME='sbt'  # Benchmark database
MYSQL_ENGINE='InnoDB'  # Database engine
MYSQL_TIME='30'  # Test duration (seconds)
MYSQL_THREADS="$(nproc)"  # Threads based on CPU cores
MYSQL_TABLECOUNT='8'  # Number of tables
MYSQL_OLTPTABLESIZE='150000'  # Table size
MYSQL_SCALE='100'  # Scaling factor
MYSQL_SSL='n'  # SSL disabled by default
MYSQL_SSL_CIPHER=''  # SSL cipher (empty if not used)

# Stats collection flags
COLLECT_MYSQLSTATS='y'  # Collect MySQL stats
COLLECT_DISKSTATS='y'  # Collect disk stats
COLLECT_PIDSTATS='y'  # Collect PID stats

# Directories
SYSBENCH_DIR='/home/sysbench'  # Root directory for outputs
SYSBENCH_FILEIODIR="${SYSBENCH_DIR}/fileio"  # File I/O test directory

# Toggle Info That Is Displayed
BASEINFO_MASK_DOCKER='y'
BASEINFO_SHOW='y'

SHOW_RESULT_JSON='y'
SHOW_RESULT_MARKDOWN='y'
SHOW_RESULT_CSV='y'
#########################################################
# JSON Mode Implementation (optional --json flag)
#########################################################
# Process optional --json flag:
JSON_MODE=0
NEWARGS=()
for arg in "$@"; do
  if [ "$arg" = "--json" ]; then
    JSON_MODE=1
  else
    NEWARGS+=("$arg")
  fi
done
if [ "$JSON_MODE" -eq 1 ]; then
  BASEINFO_SHOW='n'
  SHOW_RESULT_MARKDOWN='n'
  SHOW_RESULT_CSV='n'
fi
set -- "${NEWARGS[@]}"

# If JSON mode is enabled, override tee so that output is not printed to stdout.
if [ "$JSON_MODE" -eq 1 ]; then
  tee() {
    command tee "$@" >/dev/null
  }
fi

#########################################################
# Functions
#########################################################
SCRIPT_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))  # Script directory

# Detect OS and version from /etc/os-release
if [ -f /etc/os-release ]; then
  ELID=$(grep '^VERSION_ID=' /etc/os-release | awk -F '=' '{print $2}' | sed -e 's|"||g' | cut -d . -f1)
  OSID=$(grep '^ID=' /etc/os-release | awk -F '=' '{print $2}' | sed -e 's|"||g')
fi

# Adjust MySQL socket for Debian-based systems
if [ -f /usr/bin/apt ]; then
  MYSQL_SOCKET='/var/run/mysqld/mysqld.sock'
fi

# Create necessary directories if they don't exist
[ ! -d "$SYSBENCH_DIR" ] && mkdir -p "$SYSBENCH_DIR"
[ ! -d "$SYSBENCH_FILEIODIR" ] && mkdir -p "$SYSBENCH_FILEIODIR"
[ ! -d "${SYSBENCH_DIR}/mysql" ] && mkdir -p "${SYSBENCH_DIR}/mysql"

# Source configuration file if present
[ -f "${SCRIPT_DIR}/sysbench.ini" ] && source "${SCRIPT_DIR}/sysbench.ini"

# Set MySQL socket option
if [[ "$MYSQL_USESOCKET" = [yY] ]]; then
  MYSQL_USESOCKETOPT=" --mysql-socket=${MYSQL_SOCKET}"
  MYSQLCLIENT_USESOCKETOPT="${MYSQL_SOCKET}"
else
  MYSQL_USESOCKETOPT=""
  MYSQLCLIENT_USESOCKETOPT=""
fi

# Get sysbench version if installed
if [ -f /usr/bin/sysbench ]; then
  SYSBENCH_GETVER=$(sysbench --version | awk '{print $2}' | cut -d . -f1,3 | sed -e 's|\.||g')
fi

# Locate jemalloc library for performance optimization
if [ -f /usr/lib64/libjemalloc.so.2 ]; then
  JEMALLOC_FILE='/usr/lib64/libjemalloc.so.2'
elif [ -f /usr/lib64/libjemalloc.so.1 ]; then
  JEMALLOC_FILE='/usr/lib64/libjemalloc.so.1'
fi

mysql_create_db_user() {
  echo
  echo "Setting up $MYSQL_DBNAME database & user (2.8 style)"
  # If the database directory exists, drop it:
  if [ -d "/var/lib/mysql/$MYSQL_DBNAME" ]; then
    echo y | mysqladmin drop $MYSQL_DBNAME >/dev/null 2>&1
  fi
  echo "Creating database: $MYSQL_DBNAME"
  mysqladmin create $MYSQL_DBNAME
  # Check if the user exists (this assumes you have a /root/.my.cnf for credentials)
  mysql -e "show grants for '$MYSQL_USER'@'$MYSQL_HOST';" >/dev/null 2>&1
  CHECKUSER=$?
  if [[ "$CHECKUSER" -ne 0 ]]; then
    if [[ "$MYSQL_SSL" == [yY] ]]; then
      echo "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASS' REQUIRE SSL; \
GRANT ALL PRIVILEGES ON \`$MYSQL_DBNAME\`.* TO '$MYSQL_USER'@'$MYSQL_HOST'; \
FLUSH PRIVILEGES; SHOW GRANTS FOR '$MYSQL_USER'@'$MYSQL_HOST';" | mysql
    else
      echo "CREATE USER '$MYSQL_USER'@'$MYSQL_HOST' IDENTIFIED BY '$MYSQL_PASS'; \
GRANT ALL PRIVILEGES ON \`$MYSQL_DBNAME\`.* TO '$MYSQL_USER'@'$MYSQL_HOST'; \
FLUSH PRIVILEGES; SHOW GRANTS FOR '$MYSQL_USER'@'$MYSQL_HOST';" | mysql
    fi
  fi
}

# Set MySQL login options
set_login() {
  if [[ "$MYSQL_LOGIN" = [yY] ]]; then
    MYSQL_LOGINOPT=" --mysql-user=${MYSQL_USER} --mysql-password=${MYSQL_PASS}"
  else
    MYSQL_LOGINOPT=""
  fi
}

# Configure SSL options for MySQL
build_ssl_opts() {
  if [[ "$MYSQL_SSL" == [yY] ]]; then
    SSL_OPTS=" --mysql-ssl=on"
    MYSQL_HOST='127.0.0.1'
    [ -n "$MYSQL_SSL_CIPHER" ] && SSL_OPTS="$SSL_OPTS --mysql-ssl-cipher=$MYSQL_SSL_CIPHER"
  else
    SSL_OPTS=""
  fi
}

# Dynamically adjust parameters based on system resources
adjust_parameters() {
  MYSQL_THREADS=$(nproc)  # Set threads to number of CPU cores
  TOTAL_MEM=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)  # Memory in KB
  FILEIO_FILESIZE=$((TOTAL_MEM / 2048))  # ~50% of RAM in MB
  if [[ "$BASEINFO_SHOW" = [yY] ]]; then
    baseinfo
  fi
}

# Install additional performance tools
tools_setup() {
  wget -q -O /usr/local/bin/pmcarch https://github.com/brendangregg/pmc-cloud-tools/raw/master/pmcarch
  wget -q -O /usr/local/bin/cpucache https://github.com/brendangregg/pmc-cloud-tools/raw/master/cpucache
  wget -q -O /usr/local/bin/syscount https://github.com/brendangregg/perf-tools/raw/master/syscount
  wget -q -O /usr/local/bin/iosnoop https://github.com/brendangregg/perf-tools/raw/master/iosnoop
  wget -q -O /usr/local/bin/funccount https://github.com/brendangregg/perf-tools/raw/master/kernel/funccount
  chmod +x /usr/local/bin/pmcarch /usr/local/bin/cpucache /usr/local/bin/syscount /usr/local/bin/iosnoop /usr/local/bin/funccount
}

# Collect MySQL stats during benchmarks
get_mysqlstats() {
  local mysqltag=$1
  if [[ "$COLLECT_MYSQLSTATS" = [yY] ]]; then
    mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} ext -i10 > "$SYSBENCH_DIR/mysqlstats-${mysqltag}.log" &
    getmysqlstats_pid=$!
  fi
}

# Collect disk stats during benchmarks
get_diskstats() {
  local disktag=$1
  if [[ "$COLLECT_DISKSTATS" = [yY] ]]; then
    vmstat 1 > "$SYSBENCH_DIR/diskstats-${disktag}.log" &
    getdiskstats_pid=$!
  fi
}

# Collect PID stats during benchmarks
get_pidstats() {
  local pidstattag=$1
  if [[ "$COLLECT_PIDSTATS" = [yY] ]]; then
    pidstat -durh 1 | egrep 'sysbench|mysqld|UID' > "$SYSBENCH_DIR/pidstat-${pidstattag}.log" &
    getpidstat_pid=$!
  fi
}

# Display MySQL settings
mysqlsettings() {
  echo -e "\nMySQL Buffers"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/buffer/ {print $2,$3}' | tr -s ' ' | column -t
  echo -e "\nMySQL Limits"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/limit/ {print $2,$3}' | tr -s ' ' | column -t
  echo -e "\nMySQL Maxes"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/max/ {print $2,$3}' | tr -s ' ' | egrep -v 'limit|buffer|performance_schema' | column -t
  echo -e "\nMySQL Concurrency"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | awk -F '|' '/concurr/ {print $2,$3}' | tr -s ' ' | egrep -v 'limit|buffer|performance_schema' | column -t
  echo -e "\nMySQL Read/Write"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'reads|write' | grep -v thread | awk -F '|' '{print $2,$3}' | tr -s ' ' | egrep -v 'limit|buffer|performance_schema' | column -t
  echo -e "\nMySQL Threads"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'thread' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo -e "\nMySQL Binlog"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'binlog|log_bin' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo -e "\nMySQL InnoDB"
  mysqladmin -P ${MYSQL_PORT} -S ${MYSQLCLIENT_USESOCKETOPT} var | egrep 'innodb' | awk -F '|' '{print $2,$3}' | tr -s ' ' | column -t
  echo
}

# Display system information
baseinfo() {
  echo "-------------------------------------------"
  echo "System Information"
  echo "-------------------------------------------"
  uname -r
  echo
  [ -f /etc/redhat-release ] && cat /etc/redhat-release
  [ -f /etc/lsb-release ] && cat /etc/lsb-release
  echo
  [ -f /etc/centminmod-release ] && echo -n "Centmin Mod " && cat /etc/centminmod-release && echo
  if [ ! -f /proc/user_beancounters ]; then
    CPUFLAGS=$(cat /proc/cpuinfo | grep '^flags' | cut -d: -f2 | awk 'NR==1')
    lscpu
    echo -e "\nCPU Flags\n$CPUFLAGS"
  else
    CPUNAME=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | tr -s " " | head -n 1)
    CPUCOUNT=$(cat /proc/cpuinfo | grep "model name" | wc -l)
    CPUFLAGS=$(cat /proc/cpuinfo | grep '^flags' | cut -d: -f2 | awk 'NR==1')
    echo "CPU: $CPUCOUNT x$CPUNAME"
    uname -m
    echo -e "\nCPU Flags\n$CPUFLAGS"
  fi
  echo
  [ ! -f /proc/user_beancounters ] && lscpu -e && echo
  free -mlt
  echo
  if [[ "$BASEINFO_MASK_DOCKER" = [yY] ]]; then
    df -hT 2>&1 | egrep -v 'docker|overlay'
  else
    df -hT
  fi
  echo
}

# Update sysbench via package manager
sysbench_update() {
  echo
  if [ -d /etc/yum.repos.d ]; then
    echo "update sysbench from yum repo"
    if [ -f /etc/yum.repos.d/epel.repo ]; then
      echo "yum -y update sysbench --disablerepo=epel"
      yum -y update sysbench --disablerepo=epel || { echo "Update failed"; exit 1; }
    else
      echo "yum -y update sysbench"
      yum -y update sysbench || { echo "Update failed"; exit 1; }
    fi
  elif [ -f /usr/bin/apt ]; then
    echo "update sysbench from apt"
    sudo apt -y install sysbench || { echo "Update failed"; exit 1; }
  fi
  echo
}

# Install sysbench for AlmaLinux 9/10 (source compilation)
sysbench_install_el9() {
  if [[ "$ELID" -ge 9 && "$OSID" =~ ^(almalinux|rocky)$ ]]; then
    echo "Install sysbench dependencies..."
    yum -q -y install make automake libtool pkgconfig libaio-devel || { echo "Dependency installation failed"; exit 1; }
    echo "sysbench dependencies installed"
    echo "Install sysbench for EL${ELID}"
    mkdir -p /svr-setup
    pushd /svr-setup
    wget https://github.com/akopytov/sysbench/archive/refs/tags/1.0.20.tar.gz -O sysbench-1.0.20.tar.gz || { echo "Download failed"; exit 1; }
    tar -xzf sysbench-1.0.20.tar.gz
    cd sysbench-1.0.20
    make clean
    ./autogen.sh
    ./configure
    make -j$(nproc)
    make install || { echo "Installation failed"; exit 1; }
    mkdir -p /usr/share/sysbench/
    \cp -fa tests /usr/share/sysbench/
    \cp -fa src/lua/*.lua /usr/share/sysbench/
    popd
  fi
}

# Install sysbench based on OS
sysbench_install() {
  if [ -f /etc/os-release ]; then
    if [[ "$OSID" =~ ^(almalinux|rocky)$ ]]; then
      case "$ELID" in
        8)
          echo "yum -y install sysbench --enablerepo=epel"
          yum -y install sysbench --enablerepo=epel || { echo "Installation failed"; exit 1; }
          ;;
        9|10)
          sysbench_install_el9
          ;;
      esac
    elif [ -f /usr/bin/apt ]; then
      echo "install sysbench from apt"
      curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
      sudo apt -y install sysbench || { echo "Installation failed"; exit 1; }
    else
      echo "Unsupported OS"
      exit 1
    fi
  fi
}

# CPU benchmark
sysbench_cpu() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR"
  echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run" | tee "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  if [ -f "$JEMALLOC_FILE" ]; then
    LD_PRELOAD="$JEMALLOC_FILE" sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  else
    sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=1 run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-1.log"
  fi
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" | grep -v prime | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-cpu-threads-1.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-cpu-threads-1.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-cpu-threads-1.csv"
  # Markdown output
  echo -e "# CPU Benchmark (Single Thread)\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-cpu-threads-1.md"
  cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" | grep -v sysbench | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-cpu-threads-1.md"
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.csv"
  fi
  if [[ "$TEST_SINGLETHREAD" != [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    echo "sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=${MYSQL_THREADS} run" | tee "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log"
    if [ -f "$JEMALLOC_FILE" ]; then
      LD_PRELOAD="$JEMALLOC_FILE" sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=${MYSQL_THREADS} run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log"
    else
      sysbench cpu --cpu-max-prime=${CPU_MAXPRIME} --threads=${MYSQL_THREADS} run | egrep 'sysbench |Number of threads:|Prime numbers limit:|events per second:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|Prime numbers limit|prime|' -e 's|events per second|events/s|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log"
    fi
    # Save to JSON for HTML export
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log" | grep -v prime | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.json"
    if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
      if [ "$JSON_MODE" -eq 0 ]; then
        echo
      fi
      jq -c '.[]' "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.json"
    fi
    # CSV output
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.csv"
    # Markdown output
    echo -e "# CPU Benchmark (${MYSQL_THREADS} Threads)\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.md"
    cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log" | grep -v sysbench | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.md"
    # Display Markdown and CSV results
    if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
      echo
      cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.md"
      echo
      # --- Merge CPU markdown outputs into one table ---
      MERGED_CPU_MD="$SYSBENCH_DIR/sysbench-cpu.md"
      echo -e "| cpu sysbench | threads: | events/s: | time: | min: | avg: | max: | 95th: |" > "$MERGED_CPU_MD"
      echo -e "| --- | --- | --- | --- | --- | --- | --- | --- |" >> "$MERGED_CPU_MD"

      for logfile in "$SYSBENCH_DIR/sysbench-cpu-threads-1.log" "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.log"; do
          SYSBENCH_VER=$(grep -i "sysbench" "$logfile" | grep "(" | awk '{print $2}')
          THREADS=$(grep -i "threads:" "$logfile" | awk '{print $2}')
          EVENTS=$(grep -i "events/s:" "$logfile" | awk '{print $2}')
          TIME=$(grep -i "time:" "$logfile" | awk '{print $2}')
          MIN=$(grep -i "min:" "$logfile" | awk '{print $2}')
          AVG=$(grep -i "avg:" "$logfile" | awk '{print $2}')
          MAX=$(grep -i "max:" "$logfile" | awk '{print $2}')
          P95=$(grep -i "95th:" "$logfile" | awk '{print $2}')
          echo "| $SYSBENCH_VER | $THREADS | $EVENTS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$MERGED_CPU_MD"
      done
      echo
      cat "$MERGED_CPU_MD"
    fi
    if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
      echo
      cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.csv"
    fi
  fi
}

# Memory benchmark
sysbench_mem() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR"
  echo "sysbench memory --memory-block-size=${MEM_BLOCKSIZE}K --memory-total-size=${MEM_TOTALSIZE}G --threads=1 run" | tee "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  sysbench memory --memory-block-size=${MEM_BLOCKSIZE}K --memory-total-size=${MEM_TOTALSIZE}G --threads=1 run | egrep 'sysbench |Number of threads:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|transferred|transfer|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-1.log"
  # Save to JSON for HTML export - FIXED to correctly capture MiB/sec value
  cat "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | grep -v sysbench | awk '{
    if ($0 ~ /transfer/) {
      # Special handling for the transfer line which contains multiple values
      # Extract the transfer rate in MiB/sec from within the parentheses
      match($0, /\(([0-9.]+) MiB\/sec\)/, arr);
      print "transfer", arr[1] " MiB/sec";
    } else {
      # Normal handling for other lines
      print $1, $2;
    }
  }' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mem-threads-1.json"
  
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mem-threads-1.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mem-threads-1.csv"
  {
    echo -e "# Memory Benchmark (Single Thread)\n\n| Metric | Value |\n|--------|-------|"
    grep -v sysbench "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | while read -r line; do
      if echo "$line" | grep -qi "transfer"; then
        # Extract the transfer rate from within the parentheses.
        value=$(echo "$line" | sed -n 's/.*(\([0-9.]*\) MiB\/sec).*/\1 MiB\/sec/p')
        echo "| transfer | $value |"
      else
        # For all other lines, print the first two tokens.
        echo "$line" | awk '{print "| " $1 " | " $2 " |"}'
      fi
    done
  } > "$SYSBENCH_DIR/sysbench-mem-threads-1.md"
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mem-threads-1.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    grep -v sysbench "$SYSBENCH_DIR/sysbench-mem-threads-1.log" | while read -r line; do
        if echo "$line" | grep -qi "transfer"; then
            # Extract the per-second transfer value from within the parentheses
            value=$(echo "$line" | sed -n 's/.*(\([0-9.]*\) MiB\/sec).*/\1 MiB\/sec/p')
            echo "transfer,$value"
        else
            echo "$line" | awk '{print $1","$2}'
        fi
    done > "$SYSBENCH_DIR/sysbench-mem-threads-1.csv"
  fi
  if [[ "$TEST_SINGLETHREAD" != [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    echo "sysbench memory --memory-block-size=${MEM_BLOCKSIZE}K --memory-total-size=${MEM_TOTALSIZE}G --threads=${MYSQL_THREADS} run" | tee "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log"
    sysbench memory --memory-block-size=${MEM_BLOCKSIZE}K --memory-total-size=${MEM_TOTALSIZE}G --threads=${MYSQL_THREADS} run | egrep 'sysbench |Number of threads:|transferred|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|transferred|transfer|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log"
    # Save to JSON for HTML export - FIXED to correctly capture MiB/sec value
    cat "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log" | grep -v sysbench | awk '{
      if ($0 ~ /transfer/) {
        # Special handling for the transfer line which contains multiple values
        # Extract the transfer rate in MiB/sec from within the parentheses
        match($0, /\(([0-9.]+) MiB\/sec\)/, arr);
        print "transfer", arr[1] " MiB/sec";
      } else {
        # Normal handling for other lines
        print $1, $2;
      }
    }' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.json"
    
    if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
      if [ "$JSON_MODE" -eq 0 ]; then
        echo
      fi
      jq -c '.[]' "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.json"
    fi
    # CSV output
    grep -v sysbench "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log" | while read -r line; do
        if echo "$line" | grep -qi "transfer"; then
            # Extract the per-second transfer value from inside the parentheses
            value=$(echo "$line" | sed -n 's/.*(\([0-9.]*\) MiB\/sec).*/\1 MiB\/sec/p')
            echo "transfer,$value"
        else
            echo "$line" | awk '{print $1","$2}'
        fi
    done > "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.csv"
      # Markdown output with correct transfer rate for multi-thread memory test
      {
        echo -e "# Memory Benchmark (${MYSQL_THREADS} Threads)\n\n| Metric | Value |\n|--------|-------|"
        grep -v sysbench "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log" | while read -r line; do
          if echo "$line" | grep -qi "transfer"; then
            # Extract only the per-second transfer value (e.g. 22746.17 MiB/sec)
            value=$(echo "$line" | sed -n 's/.*(\([0-9.]*\) MiB\/sec).*/\1 MiB\/sec/p')
            echo "| transfer | $value |"
          else
            echo "$line" | awk '{print "| " $1 " | " $2 " |"}'
          fi
        done
      } > "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.md"
    # Display Markdown and CSV results
    if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
      echo
      cat "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.md"
      echo
      # --- Merge Memory markdown outputs into one table ---
      MERGED_MEM_MD="$SYSBENCH_DIR/sysbench-mem.md"
      echo -e "| memory sysbench | sysbench | threads: | block-size: | total-size: | operation: | total-ops: | transferred | time: | min: | avg: | max: | 95th: |" > "$MERGED_MEM_MD"
      echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$MERGED_MEM_MD"

      for logfile in "$SYSBENCH_DIR/sysbench-mem-threads-1.log" "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.log"; do
          # Extract the sysbench version if available (you might hardcode or extract from elsewhere)
          MEM_SYSBENCH="1.0.20"
          THREADS=$(grep -i "threads:" "$logfile" | awk '{print $2}')
          # For memory tests, you might have a different line for block size and total size.
          # Adjust these awk/grep commands as needed based on your log format.
          FIRST_LINE=$(head -n1 "$logfile")
          BLOCKSIZE=$(echo "$FIRST_LINE" | sed -n 's/.*--memory-block-size=\([^ ]*\).*/\1/p')
          TOTALSIZE_RAW=$(echo "$FIRST_LINE" | sed -n 's/.*--memory-total-size=\([^ ]*\).*/\1/p')
          # Convert a value ending in "G" to MiB (e.g. "1G" to "1024MiB")
          if [[ $TOTALSIZE_RAW =~ G ]]; then
              NUM=$(echo "$TOTALSIZE_RAW" | sed 's/[^0-9.]//g')
              TOTALSIZE=$(printf "%.0fMiB" "$(echo "$NUM * 1024" | bc -l)")
          else
              TOTALSIZE=$TOTALSIZE_RAW
          fi
          # For the operation type and total-ops you might need custom parsing.
          # Here we assume "transfer" field holds the transferred rate.
          TRANSFER=$(grep -i "transfer" "$logfile" | sed -n 's/.*(\([0-9.]*\) MiB\/sec).*/\1/p')
          TIME=$(grep -i "time:" "$logfile" | awk '{print $2}')
          MIN=$(grep -i "min:" "$logfile" | awk '{print $2}')
          AVG=$(grep -i "avg:" "$logfile" | awk '{print $2}')
          MAX=$(grep -i "max:" "$logfile" | awk '{print $2}')
          P95=$(grep -i "95th:" "$logfile" | awk '{print $2}')
          # For demonstration, we hardcode the operation as "read" and total-ops as "1048576".
          # You may adjust this to parse actual values from your logs.
          OPERATION="read"
          TOTALOPS="1048576"
          echo "| memory | $MEM_SYSBENCH | $THREADS | ${BLOCKSIZE}KiB | ${TOTALSIZE}MiB | $OPERATION | $TOTALOPS | $TRANSFER | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$MERGED_MEM_MD"
      done
      echo
      cat "$MERGED_MEM_MD"
    fi
    if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
      echo
      cat "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.csv"
    fi
  fi
}

# File I/O benchmark with support for different block sizes and fsync
sysbench_fileio() {
  local block_size=$1  # e.g., 16 for 16k, 64 for 64k, etc.
  local test_mode=$2   # e.g., seqrd, seqwr, fsync
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_FILEIODIR"
  local file_size=$FILEIO_FILESIZE
  local block_size_bytes=$FILEIO_BLOCKSIZE
  if [ -n "$block_size" ]; then
    block_size_bytes=$((block_size * 1024))  # Convert KB to bytes
  fi
  local mode_label="${test_mode:-seqwr}-${block_size:-default}"
  if [ "$test_mode" = "fsync" ]; then
    if [ "$JSON_MODE" -eq 1 ]; then
      sysbench fileio --file-num=1 --file-total-size=4096 --file-block-size=${block_size_bytes} \
        --file-fsync-all=on --file-test-mode=rndwr --time=${FILEIO_FSYNCTIME} prepare >/dev/null 2>&1
    else
      echo "sysbench fileio --file-num=1 --file-total-size=4096 --file-block-size=${block_size_bytes} --file-fsync-all=on --file-test-mode=rndwr --time=${FILEIO_FSYNCTIME} prepare"
      sysbench fileio --file-num=1 --file-total-size=4096 --file-block-size=${block_size_bytes} \
        --file-fsync-all=on --file-test-mode=rndwr --time=${FILEIO_FSYNCTIME} prepare >/dev/null 2>&1
    fi
    sysbench fileio --file-num=1 --file-total-size=4096 --file-block-size=${block_size_bytes} \
      --file-fsync-all=on --file-test-mode=rndwr --time=${FILEIO_FSYNCTIME} run \
      | egrep 'sysbench |reads/s|writes/s|fsyncs/s|throughput|total time:' \
      | tee "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log"
  else
    if [ "$JSON_MODE" -eq 1 ]; then
      sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M \
        --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} \
        --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} prepare >/dev/null 2>&1
    else
      echo "sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} prepare"
      sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M \
        --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} \
        --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} prepare >/dev/null 2>&1
    fi
    sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M \
      --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} \
      --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} run \
      | egrep 'sysbench |reads/s|writes/s|fsyncs/s|throughput|total time:' \
      | tee "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log"
  fi
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | grep -v sysbench | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/fileio_${mode_label}.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/fileio_${mode_label}.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.csv"
  # New Markdown output for File I/O Benchmark (single row)
  {
    # Extract metric values from the log file
    reads=$(grep "reads/s:" "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | awk '{print $2}')
    writes=$(grep "writes/s:" "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | awk '{print $2}')
    fsyncs=$(grep "fsyncs/s:" "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | awk '{print $2}')
    total_time=$(grep "total time:" "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.log" | awk '{print $3}')

    # You can add additional processing if needed for read-MiB/s, written-MiB/s, min, avg, max, 95th, etc.
    
    # Write header
    echo -e "# File I/O Benchmark (${mode_label})\n" > "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.md"
    echo -e "| fileio sysbench | sysbench | threads: | Block-size | synchronous | random | reads/s: | writes/s: | fsyncs/s: | read-MiB/s: | written-MiB/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.md"
    echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.md"

    # Write one row with hardcoded values for the first columns and the extracted metrics
    # Adjust hardcoded values as needed; here "N/A" is used for fields not available.
    echo -e "| fileio | 1.0.14 | 1 | 4KiB | I/O | read | $reads | $writes | $fsyncs | N/A | N/A | $total_time | N/A | N/A | N/A | N/A |" >> "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.md"
  } 

  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-fileio-${mode_label}.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M \
      --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} \
      --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} cleanup >/dev/null 2>&1
  else
    sysbench fileio --file-num=${FILEIO_FILENUM} --file-total-size=${file_size}M \
      --file-test-mode=${test_mode:-seqwr} --file-extra-flags=${FILEIO_EXTRAFLAGS} \
      --file-block-size=${block_size_bytes} --file-io-mode=${FILEIO_MODE} --time=${FILEIO_TIME} cleanup
  fi
}

# MySQL benchmark (standard OLTP read/write)
sysbench_mysqloltp() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare" > "$SYSBENCH_DIR/sysbench-mysql.log"
    sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare" | tee "$SYSBENCH_DIR/sysbench-mysql.log"
    sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysql
  get_diskstats mysql
  get_pidstats mysql
  sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysql.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysql.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysql.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysql.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysql.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysql.csv"
  
  # Markdown output
  echo -e "# MySQL Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysql.md"
  cat "$SYSBENCH_DIR/sysbench-mysql.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysql.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysql.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysql.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysql.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysql.log" | awk '{print $2}')

  echo -e "| oltp_read_write | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysql.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysql-full.csv"
  echo "oltp_read_write,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysql-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysql.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysql.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysql-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 cleanup >/dev/null 2>&1
  else
    sysbench oltp_read_write --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 cleanup
  fi
}

# MySQL read-only benchmark
sysbench_mysqlro() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlro.log"
    sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlro.log"
    sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlro
  get_diskstats mysqlro
  get_pidstats mysqlro
  sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlro.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlro.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlro.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlro.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlro.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlro.csv"
  
  # Markdown output
  echo -e "# MySQL Read-Only Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlro.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlro.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlro.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlro.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlro.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlro.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlro.log" | awk '{print $2}')

  echo -e "| oltp_read_only | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlro.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlro-full.csv"
  echo "oltp_read_only,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlro-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench oltp_read_only --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL insert benchmark
sysbench_mysqlinsert() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlinsert.log"
    sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlinsert.log"
    sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlinsert
  get_diskstats mysqlinsert
  get_pidstats mysqlinsert
  sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlinsert.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlinsert.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlinsert.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlinsert.csv"
  
  # Markdown output
  echo -e "# MySQL Insert Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlinsert.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlinsert.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlinsert.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlinsert.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlinsert.log" | awk '{print $2}')

  echo -e "| oltp_insert | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlinsert.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlinsert-full.csv"
  echo "oltp_insert,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlinsert-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlinsert.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlinsert.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlinsert-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench oltp_insert --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL update index benchmark
sysbench_mysqlupdateindex() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log"
    sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log"
    sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlupdateindex
  get_diskstats mysqlupdateindex
  get_pidstats mysqlupdateindex
  sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlupdateindex.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlupdateindex.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlupdateindex.csv"
  
  # Markdown output
  echo -e "# MySQL Update Index Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlupdateindex.log" | awk '{print $2}')

  echo -e "| oltp_update_index | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlupdateindex-full.csv"
  echo "oltp_update_index,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlupdateindex-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench oltp_update_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL update non-index benchmark
sysbench_mysqlupdatenonindex() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log"
    sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log"
    sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlupdatenonindex
  get_diskstats mysqlupdatenonindex
  get_pidstats mysqlupdatenonindex
  sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.csv"
  
  # Markdown output
  echo -e "# MySQL Update Non-Index Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.log" | awk '{print $2}')

  echo -e "| oltp_update_non_index | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex-full.csv"
  echo "oltp_update_non_index,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench oltp_update_non_index --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL OLTP new benchmark
sysbench_mysqloltp_new() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare" > "$SYSBENCH_DIR/sysbench-mysqloltp_new.log"
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare" | tee "$SYSBENCH_DIR/sysbench-mysqloltp_new.log"
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqloltp_new
  get_diskstats mysqloltp_new
  get_pidstats mysqloltp_new
  sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqloltp_new.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqloltp_new.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqloltp_new.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqloltp_new.csv"
  
  # Markdown output
  echo -e "# MySQL OLTP New Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"
  cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqloltp_new.log" | awk '{print $2}')

  echo -e "| oltp_read_write | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqloltp_new-full.csv"
  echo "oltp_read_write,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqloltp_new-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqloltp_new-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 cleanup >/dev/null 2>&1
  else
    sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} --report-interval=2 cleanup
  fi
}

# MySQL read-only new benchmark
sysbench_mysqlro_new() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlro_new.log"
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlro_new.log"
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlro_new
  get_diskstats mysqlro_new
  get_pidstats mysqlro_new
  sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlro_new.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlro_new.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlro_new.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlro_new.csv"
  
  # Markdown output
  echo -e "# MySQL Read-Only New Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlro_new.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlro_new.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlro_new.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlro_new.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlro_new.log" | awk '{print $2}')

  echo -e "| oltp_read_only | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlro_new.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlro_new-full.csv"
  echo "oltp_read_only,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlro_new-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro_new.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro_new.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlro_new-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench /usr/share/sysbench/oltp_read_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL write-only new benchmark
sysbench_mysqlwo_new() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlwo_new.log"
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlwo_new.log"
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlwo_new
  get_diskstats mysqlwo_new
  get_pidstats mysqlwo_new
  sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlwo_new.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlwo_new.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlwo_new.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlwo_new.csv"
  
  # Markdown output
  echo -e "# MySQL Write-Only New Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"

  # Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlwo_new.log" | awk '{print $2}')

  echo -e "| oltp_write_only | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlwo_new-full.csv"
  echo "oltp_write_only,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlwo_new-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlwo_new-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench /usr/share/sysbench/oltp_write_only.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# MySQL point-select new benchmark
sysbench_mysqlpointselect_new() {
  if ! command -v sysbench >/dev/null 2>&1; then
    sysbench_install
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  cd "$SYSBENCH_DIR/mysql"
  set_login
  build_ssl_opts
  if [ "$JSON_MODE" -eq 1 ]; then
    mysql_create_db_user >/dev/null 2>&1
    echo "sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" > "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log"
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare >/dev/null 2>&1
  else
    mysql_create_db_user
    echo "sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare" | tee "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log"
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} prepare
  fi
  if [ "$JSON_MODE" -eq 0 ]; then
    echo
  fi
  get_mysqlstats mysqlpointselect_new
  get_diskstats mysqlpointselect_new
  get_pidstats mysqlpointselect_new
  sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} run | egrep 'sysbench |Number of threads:|read:|write:|other:|total:|transactions:|queries:|total time:|min:|avg:|max:|95th percentile:' | sed -e 's|Number of threads|threads|' -e 's|total time:|time:|' -e 's| percentile||' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -s ' ' | tee -a "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log"
  kill $getmysqlstats_pid
  # Save to JSON for HTML export
  cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print $1,$2}' | jq -R 'split(" ") | {key: .[0], value: .[1]}' | jq -s '.' > "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.json"
  if [[ "$SHOW_RESULT_JSON" = [yY] ]]; then
    if [ "$JSON_MODE" -eq 0 ]; then
      echo
    fi
    jq -c '.[]' "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.json"
  fi
  # CSV output
  cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | grep -v sysbench | awk '{print $1","$2}' > "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.csv"
  
  # Markdown output
  echo -e "# MySQL Point-Select New Benchmark\n\n| Metric | Value |\n|--------|-------|" > "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"
  cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | grep -v sysbench | sed -e 's/^[[:space:]]*total time:/time:/' -e 's/^[[:space:]]*total:/total:/' | awk '{print "| " $1 " | " $2 " |"}' >> "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"

  # Also add the more comprehensive table format from 2.8
  echo -e "\n| mysql sysbench | sysbench | threads: | read: | write: | other: | total: | transactions/s: | queries/s: | time: | min: | avg: | max: | 95th: |" >> "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"
  echo -e "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |" >> "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"

# Extract the sysbench version
  SYSBENCH_VER=$(grep -i "sysbench" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | head -1 | awk '{print $2}')
  # Extract values from the log
  THREADS=$(grep -i "threads:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  READ=$(grep -i "read:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  WRITE=$(grep -i "write:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  OTHER=$(grep -i "other:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  TOTAL=$(grep -i "total:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  TPS=$(grep -i "transactions:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  QPS=$(grep -i "queries:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $3}' | sed -e 's/[)(]//g')
  TIME=$(grep -i "time:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  MIN=$(grep -i "min:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  AVG=$(grep -i "avg:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  MAX=$(grep -i "max:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')
  P95=$(grep -i "95th:" "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.log" | awk '{print $2}')

  echo -e "| oltp_point_select | $SYSBENCH_VER | $THREADS | $READ | $WRITE | $OTHER | $TOTAL | $TPS | $QPS | $TIME | $MIN | $AVG | $MAX | $P95 |" >> "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"

  # Add the more comprehensive CSV format from 2.8
  echo "sysbench,sysbench,threads,read,write,other,total,transactions/s,queries/s,time,min,avg,max,95th" > "$SYSBENCH_DIR/sysbench-mysqlpointselect_new-full.csv"
  echo "oltp_point_select,$SYSBENCH_VER,$THREADS,$READ,$WRITE,$OTHER,$TOTAL,$TPS,$QPS,$TIME,$MIN,$AVG,$MAX,$P95" >> "$SYSBENCH_DIR/sysbench-mysqlpointselect_new-full.csv"
  
  # Display Markdown and CSV results
  if [[ "$SHOW_RESULT_MARKDOWN" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.md"
  fi
  if [[ "$SHOW_RESULT_CSV" = [yY] ]]; then
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.csv"
    echo
    cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new-full.csv"
  fi
  if [ "$JSON_MODE" -eq 1 ]; then
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup >/dev/null 2>&1
  else
    sysbench /usr/share/sysbench/oltp_point_select.lua --mysql-host=${MYSQL_HOST} --mysql-port=${MYSQL_PORT}${MYSQL_USESOCKETOPT}${MYSQL_LOGINOPT}${SSL_OPTS} --mysql-db=${MYSQL_DBNAME} --tables=${MYSQL_TABLECOUNT} --table-size=${MYSQL_OLTPTABLESIZE} --threads=${MYSQL_THREADS} --time=${MYSQL_TIME} cleanup
  fi
}

# Generate HTML report with Highcharts
generate_html_report() {
  local OUTPUT_DIR=${1:-$SYSBENCH_DIR}
  
  # Generate an array of available MySQL files
  local MYSQL_TYPES=(mysql mysqlro mysqlinsert mysqlupdateindex mysqlupdatenonindex mysqloltp_new mysqlro_new mysqlwo_new mysqlpointselect_new)
  local MYSQL_FILES_LIST="["
  
  for TYPE in "${MYSQL_TYPES[@]}"; do
    if [ -f "$SYSBENCH_DIR/sysbench-${TYPE}.json" ]; then
      MYSQL_FILES_LIST+="\"$TYPE\", "
    fi
  done
  
  # Remove trailing comma and space and close the array
  MYSQL_FILES_LIST=$(echo "$MYSQL_FILES_LIST" | sed 's/, $//')"]"
  
  # Load CPU Data
  local CPU_DATA_SINGLE="[]"
  local CPU_DATA_MULTI="[]"
  if [ -f "$SYSBENCH_DIR/sysbench-cpu-threads-1.json" ]; then
    CPU_DATA_SINGLE=$(cat "$SYSBENCH_DIR/sysbench-cpu-threads-1.json" 2>/dev/null || echo "[]")
  fi
  if [ -f "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.json" ]; then
    CPU_DATA_MULTI=$(cat "$SYSBENCH_DIR/sysbench-cpu-threads-${MYSQL_THREADS}.json" 2>/dev/null || echo "[]")
  fi
  
  # Load Memory Data
  local MEM_DATA_SINGLE="[]"
  local MEM_DATA_MULTI="[]"
  if [ -f "$SYSBENCH_DIR/sysbench-mem-threads-1.json" ]; then
    MEM_DATA_SINGLE=$(cat "$SYSBENCH_DIR/sysbench-mem-threads-1.json" 2>/dev/null || echo "[]")
  fi
  if [ -f "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.json" ]; then
    MEM_DATA_MULTI=$(cat "$SYSBENCH_DIR/sysbench-mem-threads-${MYSQL_THREADS}.json" 2>/dev/null || echo "[]")
  fi
  
  # Load FileIO Data
  local FILEIO_DATA="[]"
  if [ -f "$SYSBENCH_DIR/fileio_seqwr-default.json" ]; then
    FILEIO_DATA=$(cat "$SYSBENCH_DIR/fileio_seqwr-default.json" 2>/dev/null || echo "[]")
  elif [ -f "$SYSBENCH_DIR/fileio_seqwr-16.json" ]; then
    FILEIO_DATA=$(cat "$SYSBENCH_DIR/fileio_seqwr-16.json" 2>/dev/null || echo "[]")
  fi
  
  # Instead of trying to embed the JSON directly, we'll load the files using Ajax
  cat <<EOF > "$OUTPUT_DIR/sysbench_report.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sysbench Benchmark Report</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/css/bootstrap.min.css">
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/highcharts-3d.js"></script>
    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f8f9fa; color: #333; }
        h1, h2, h3 { color: #007bff; }
        h3 { margin-top: 30px; }
        .table-striped tbody tr:nth-of-type(odd) { background-color: #e9ecef; }
        .chart-container { border: 1px solid #dee2e6; border-radius: 5px; padding: 10px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mt-5">Sysbench Benchmark Report</h1>
        
        <!-- CPU section -->
        <h2>CPU Performance</h2>
        <div id="cpu-chart" class="chart-container" style="height: 400px;"></div>
        <table class="table table-striped">
            <thead><tr><th>Threads</th><th>Events/s</th><th>Time</th><th>Min</th><th>Avg</th><th>Max</th><th>95th</th></tr></thead>
            <tbody id="cpu-table"></tbody>
        </table>
        
        <!-- Memory section -->
        <h2>Memory Performance</h2>
        <div id="mem-chart" class="chart-container" style="height: 400px;"></div>
        <table class="table table-striped">
            <thead><tr><th>Threads</th><th>Transfer</th><th>Time</th><th>Min</th><th>Avg</th><th>Max</th><th>95th</th></tr></thead>
            <tbody id="mem-table"></tbody>
        </table>
        
        <!-- File I/O section -->
        <h2>File I/O Performance</h2>
        <div id="fileio-chart" class="chart-container" style="height: 400px;"></div>
        <table class="table table-striped">
            <thead><tr><th>Metric</th><th>Value</th></tr></thead>
            <tbody id="fileio-table"></tbody>
        </table>
        
        <!-- MySQL section -->
        <h2>MySQL Performance</h2>
        <div id="mysql-sections"></div>
    </div>
    <script>
        // CPU Chart and Table
        const cpuDataSingle = ${CPU_DATA_SINGLE};
        const cpuDataMulti = ${CPU_DATA_MULTI};
        
        if (cpuDataSingle.length > 0 || cpuDataMulti.length > 0) {
            // Create chart
            Highcharts.chart('cpu-chart', {
                chart: { type: 'column', options3d: { enabled: true, alpha: 15, beta: 15 } },
                title: { text: 'CPU Benchmark Results' },
                xAxis: { categories: ['Events/s', 'Min', 'Avg', 'Max', '95th'] },
                yAxis: { title: { text: 'Value' } },
                plotOptions: {
                    column: {
                        dataLabels: {
                            enabled: true,
                            formatter: function() {
                                if (this.point.category === 'Events/s') {
                                    return this.y.toLocaleString('en-US', {maximumFractionDigits: 2});
                                }
                                return this.y.toFixed(2);
                            },
                            style: {
                                fontSize: '10px'
                            },
                            rotation: 0,         // No rotation
                            align: 'center',
                            verticalAlign: 'top',
                            y: -20,              // Higher position above bar
                            x: 0                 // Center horizontally
                        }
                    }
                },
                series: [
                    { 
                        name: 'Single Thread',
                        data: [
                            cpuDataSingle.find(d => d.key === 'events/s:')?.value ? parseFloat(cpuDataSingle.find(d => d.key === 'events/s:')?.value) : 0,
                            cpuDataSingle.find(d => d.key === 'min:')?.value ? parseFloat(cpuDataSingle.find(d => d.key === 'min:')?.value) : 0,
                            cpuDataSingle.find(d => d.key === 'avg:')?.value ? parseFloat(cpuDataSingle.find(d => d.key === 'avg:')?.value) : 0,
                            cpuDataSingle.find(d => d.key === 'max:')?.value ? parseFloat(cpuDataSingle.find(d => d.key === 'max:')?.value) : 0,
                            cpuDataSingle.find(d => d.key === '95th:')?.value ? parseFloat(cpuDataSingle.find(d => d.key === '95th:')?.value) : 0
                        ]
                    },
                    {
                        name: 'Multi Thread',
                        data: [
                            cpuDataMulti.find(d => d.key === 'events/s:')?.value ? parseFloat(cpuDataMulti.find(d => d.key === 'events/s:')?.value) : 0,
                            cpuDataMulti.find(d => d.key === 'min:')?.value ? parseFloat(cpuDataMulti.find(d => d.key === 'min:')?.value) : 0,
                            cpuDataMulti.find(d => d.key === 'avg:')?.value ? parseFloat(cpuDataMulti.find(d => d.key === 'avg:')?.value) : 0,
                            cpuDataMulti.find(d => d.key === 'max:')?.value ? parseFloat(cpuDataMulti.find(d => d.key === 'max:')?.value) : 0,
                            cpuDataMulti.find(d => d.key === '95th:')?.value ? parseFloat(cpuDataMulti.find(d => d.key === '95th:')?.value) : 0
                        ]
                    }
                ]
            });
            
            // Populate table with proper units
            let cpuTableHtml = '';
            if (cpuDataSingle.length > 0) {
                cpuTableHtml += '<tr><td>1</td>' + 
                    '<td>' + (cpuDataSingle.find(d => d.key === 'events/s:')?.value || 'N/A') + ' events/s</td>' +
                    '<td>' + (cpuDataSingle.find(d => d.key === 'time:')?.value || 'N/A') + ' s</td>' +
                    '<td>' + (cpuDataSingle.find(d => d.key === 'min:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataSingle.find(d => d.key === 'avg:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataSingle.find(d => d.key === 'max:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataSingle.find(d => d.key === '95th:')?.value || 'N/A') + ' ms</td></tr>';
            }
            if (cpuDataMulti.length > 0) {
                cpuTableHtml += '<tr><td>' + (cpuDataMulti.find(d => d.key === 'threads:')?.value || 'N/A') + '</td>' + 
                    '<td>' + (cpuDataMulti.find(d => d.key === 'events/s:')?.value || 'N/A') + ' events/s</td>' +
                    '<td>' + (cpuDataMulti.find(d => d.key === 'time:')?.value || 'N/A') + ' s</td>' +
                    '<td>' + (cpuDataMulti.find(d => d.key === 'min:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataMulti.find(d => d.key === 'avg:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataMulti.find(d => d.key === 'max:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (cpuDataMulti.find(d => d.key === '95th:')?.value || 'N/A') + ' ms</td></tr>';
            }
            document.getElementById('cpu-table').innerHTML = cpuTableHtml || '<tr><td colspan="7">No data available</td></tr>';
        } else {
            document.getElementById('cpu-chart').innerHTML = '<div class="alert alert-warning">No CPU benchmark data available</div>';
            document.getElementById('cpu-table').innerHTML = '<tr><td colspan="7">No data available</td></tr>';
        }
        
        // Memory Chart and Table
        const memDataSingle = ${MEM_DATA_SINGLE};
        const memDataMulti = ${MEM_DATA_MULTI};
        
        if (memDataSingle.length > 0 || memDataMulti.length > 0) {
            // Create chart
            Highcharts.chart('mem-chart', {
                chart: { type: 'column', options3d: { enabled: true, alpha: 15, beta: 15 } },
                title: { text: 'Memory Benchmark Results' },
                xAxis: { categories: ['Transfer (MiB/s)', 'Min (ms)', 'Avg (ms)', 'Max (ms)', '95th (ms)'] },
                yAxis: { title: { text: 'Value' } },
                plotOptions: {
                    column: {
                        dataLabels: {
                            enabled: true,
                            formatter: function() {
                                if (this.point.category === 'Transfer (MiB/s)') {
                                    return this.y.toFixed(2) + ' MiB/s';
                                }
                                return this.y.toFixed(2);
                            }
                        }
                    }
                },
                series: [
                    { 
                        name: 'Single Thread',
                        data: [
                            memDataSingle.find(d => d.key === 'transfer')?.value ? parseFloat(memDataSingle.find(d => d.key === 'transfer')?.value.match(/^[\d.]+/)?.[0] || 0) : 0,
                            memDataSingle.find(d => d.key === 'min:')?.value ? parseFloat(memDataSingle.find(d => d.key === 'min:')?.value) : 0,
                            memDataSingle.find(d => d.key === 'avg:')?.value ? parseFloat(memDataSingle.find(d => d.key === 'avg:')?.value) : 0,
                            memDataSingle.find(d => d.key === 'max:')?.value ? parseFloat(memDataSingle.find(d => d.key === 'max:')?.value) : 0,
                            memDataSingle.find(d => d.key === '95th:')?.value ? parseFloat(memDataSingle.find(d => d.key === '95th:')?.value) : 0
                        ]
                    },
                    {
                        name: 'Multi Thread',
                        data: [
                            memDataMulti.find(d => d.key === 'transfer')?.value ? parseFloat(memDataMulti.find(d => d.key === 'transfer')?.value.match(/^[\d.]+/)?.[0] || 0) : 0,
                            memDataMulti.find(d => d.key === 'min:')?.value ? parseFloat(memDataMulti.find(d => d.key === 'min:')?.value) : 0,
                            memDataMulti.find(d => d.key === 'avg:')?.value ? parseFloat(memDataMulti.find(d => d.key === 'avg:')?.value) : 0,
                            memDataMulti.find(d => d.key === 'max:')?.value ? parseFloat(memDataMulti.find(d => d.key === 'max:')?.value) : 0,
                            memDataMulti.find(d => d.key === '95th:')?.value ? parseFloat(memDataMulti.find(d => d.key === '95th:')?.value) : 0
                        ]
                    }
                ]
            });
            
            // Populate table with proper units
            let memTableHtml = '';
            if (memDataSingle.length > 0) {
                // The transfer rate is already in the format like "22783.17 MiB/sec"
                memTableHtml += '<tr><td>1</td>' + 
                    '<td>' + (memDataSingle.find(d => d.key === 'transfer')?.value || 'N/A') + '</td>' +
                    '<td>' + (memDataSingle.find(d => d.key === 'time:')?.value || 'N/A') + ' s</td>' +
                    '<td>' + (memDataSingle.find(d => d.key === 'min:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataSingle.find(d => d.key === 'avg:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataSingle.find(d => d.key === 'max:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataSingle.find(d => d.key === '95th:')?.value || 'N/A') + ' ms</td></tr>';
            }
            if (memDataMulti.length > 0) {
                memTableHtml += '<tr><td>' + (memDataMulti.find(d => d.key === 'threads:')?.value || 'N/A') + '</td>' + 
                    '<td>' + (memDataMulti.find(d => d.key === 'transfer')?.value || 'N/A') + '</td>' +
                    '<td>' + (memDataMulti.find(d => d.key === 'time:')?.value || 'N/A') + ' s</td>' +
                    '<td>' + (memDataMulti.find(d => d.key === 'min:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataMulti.find(d => d.key === 'avg:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataMulti.find(d => d.key === 'max:')?.value || 'N/A') + ' ms</td>' +
                    '<td>' + (memDataMulti.find(d => d.key === '95th:')?.value || 'N/A') + ' ms</td></tr>';
            }
            document.getElementById('mem-table').innerHTML = memTableHtml || '<tr><td colspan="7">No data available</td></tr>';
        } else {
            document.getElementById('mem-chart').innerHTML = '<div class="alert alert-warning">No Memory benchmark data available</div>';
            document.getElementById('mem-table').innerHTML = '<tr><td colspan="7">No data available</td></tr>';
        }
        
        // FileIO Chart and Table
        const fileioData = ${FILEIO_DATA};

        // Add this pre-processing to fix the total time issue
        const processedFileioData = fileioData.filter(item => {
            // Filter out any standalone "total" entries that were incorrectly split
            return item.key !== "total" || (item.key === "total" && item.value !== "time:");
        }).map(item => {
            // Convert "total time:" entries to proper format if needed
            if (item.key === "total time:") {
                return { key: "total-time:", value: item.value };
            }
            return item;
        });
        
        if (fileioData.length > 0) {
            // Create chart
            Highcharts.chart('fileio-chart', {
                chart: { type: 'column', options3d: { enabled: true, alpha: 15, beta: 15 } },
                title: { text: 'File I/O Benchmark Results' },
                xAxis: { 
                    categories: processedFileioData
                        .filter(d => d.key !== 'total-time:') // Filter out total-time from chart
                        .map(d => {
                            // Add units to category labels
                            if (d.key === 'reads/s:') return 'Reads/s';
                            if (d.key === 'writes/s:') return 'Writes/s';
                            if (d.key === 'fsyncs/s:') return 'Fsyncs/s';
                            return d.key;
                        }),
                    labels: { rotation: -45 }
                },
                yAxis: { title: { text: 'Operations per second' } },
                plotOptions: {
                    column: {
                        dataLabels: {
                            enabled: true,
                            formatter: function() {
                                return this.y.toFixed(2);
                            }
                        }
                    }
                },
                series: [{ 
                    name: 'Value', 
                    data: processedFileioData
                        .filter(d => d.key !== 'total-time:') // Filter out total-time from chart
                        .map(d => {
                            const valueStr = d.value.toString();
                            const numMatch = valueStr.match(/^[\d.]+/);
                            return numMatch ? parseFloat(numMatch[0]) : 0;
                        })
                }]
            });
            
            // Populate table with units - use the complete dataset here
            let fileioTableHtml = '';
            processedFileioData.forEach(d => {
                let metricName = d.key;
                // Add appropriate units to metrics
                if (d.key === 'reads/s:') metricName = 'Reads per second';
                else if (d.key === 'writes/s:') metricName = 'Writes per second';
                else if (d.key === 'fsyncs/s:') metricName = 'Fsyncs per second';
                else if (d.key === 'total-time:') metricName = 'Total Time (seconds)';
                
                fileioTableHtml += '<tr><td>' + metricName + '</td><td>' + d.value + '</td></tr>';
            });
            document.getElementById('fileio-table').innerHTML = fileioTableHtml || '<tr><td colspan="2">No data available</td></tr>';
        } else {
            document.getElementById('fileio-chart').innerHTML = '<div class="alert alert-warning">No File I/O benchmark data available</div>';
            document.getElementById('fileio-table').innerHTML = '<tr><td colspan="2">No data available</td></tr>';
        }
        
        // MySQL Section
        const mysqlTypes = {
            "mysql": "MySQL OLTP",
            "mysqlro": "MySQL Read-Only",
            "mysqlinsert": "MySQL Insert",
            "mysqlupdateindex": "MySQL Update Index",
            "mysqlupdatenonindex": "MySQL Update Non-Index",
            "mysqloltp_new": "MySQL OLTP New",
            "mysqlro_new": "MySQL Read-Only New",
            "mysqlwo_new": "MySQL Write-Only New",
            "mysqlpointselect_new": "MySQL Point Select New"
        };
        
        // Hardcoded MySQL data for all available MySQL benchmarks
        const availableMysqlFiles = ${MYSQL_FILES_LIST};
        const mysqlData = {};
        
        // For each MySQL file, load the data
        for (const fileId of availableMysqlFiles) {
            // Load the contents of each file directly - static data
            if (fileId === "mysqloltp_new") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqloltp_new.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysql") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysql.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlro") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlro.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlinsert") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlinsert.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlupdateindex") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlupdateindex.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlupdatenonindex") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlupdatenonindex.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlro_new") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlro_new.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlwo_new") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlwo_new.json" 2>/dev/null || echo "[]");
            }
            else if (fileId === "mysqlpointselect_new") {
                mysqlData[fileId] = $(cat "$SYSBENCH_DIR/sysbench-mysqlpointselect_new.json" 2>/dev/null || echo "[]");
            }
        }
        
        // Generate MySQL sections HTML
        let mysqlSectionsHtml = '';
        
        if (availableMysqlFiles.length === 0) {
            mysqlSectionsHtml = '<div class="alert alert-info">No MySQL benchmark data available</div>';
        } else {
            for (const fileId of availableMysqlFiles) {
                const name = mysqlTypes[fileId] || fileId;
                const chartId = 'mysql-chart-' + fileId;
                const tableId = 'mysql-table-' + fileId;
                
                mysqlSectionsHtml += '<h3>' + name + '</h3>' +
                    '<div id="' + chartId + '" class="chart-container" style="height: 400px;"></div>' +
                    '<table class="table table-striped">' +
                    '<thead><tr><th>Metric</th><th>Value</th></tr></thead>' +
                    '<tbody id="' + tableId + '"></tbody>' +
                    '</table>';
            }
        }
        
        document.getElementById('mysql-sections').innerHTML = mysqlSectionsHtml;
        
        // Create charts and tables for MySQL data
        if (availableMysqlFiles.length > 0) {
            for (const fileId of availableMysqlFiles) {
                const name = mysqlTypes[fileId] || fileId;
                const data = mysqlData[fileId];
                const chartId = 'mysql-chart-' + fileId;
                const tableId = 'mysql-table-' + fileId;
                
                if (!data || data.length === 0) {
                    document.getElementById(chartId).innerHTML = '<div class="alert alert-warning">No data available</div>';
                    continue;
                }
                
                // Create chart
                Highcharts.chart(chartId, {
                    chart: { type: 'column', options3d: { enabled: true, alpha: 15, beta: 15 } },
                    title: { text: name + ' Benchmark Results' },
                    xAxis: { 
                        categories: data.map(d => {
                            // Add units to category labels
                            if (d.key === 'read:') return 'Read Ops';
                            if (d.key === 'write:') return 'Write Ops';
                            if (d.key === 'other:') return 'Other Ops';
                            if (d.key === 'total:') return 'Total Ops';
                            if (d.key === 'transactions:') return 'Transactions';
                            if (d.key === 'queries:') return 'Queries';
                            if (d.key === 'min:') return 'Min (ms)';
                            if (d.key === 'avg:') return 'Avg (ms)';
                            if (d.key === 'max:') return 'Max (ms)';
                            if (d.key === '95th:') return '95th (ms)';
                            return d.key;
                        }),
                        labels: { rotation: -45 }
                    },
                    yAxis: { title: { text: 'Value' } },
                    plotOptions: {
                        column: {
                            dataLabels: {
                                enabled: true,
                                formatter: function() {
                                    const category = this.point.category;
                                    if (category === 'Transactions' || category === 'Queries') {
                                        return this.y.toLocaleString('en-US', {maximumFractionDigits: 0});
                                    }
                                    return this.y.toLocaleString('en-US', {maximumFractionDigits: 2});
                                }
                            }
                        }
                    },
                    series: [{ 
                        name: 'Value', 
                        data: data
                            .filter(d => d.key !== 'threads:' && d.key !== 'time:')
                            .map(d => {
                                const valueStr = d.value.toString();
                                const numMatch = valueStr.match(/^[\d.]+/);
                                return numMatch ? parseFloat(numMatch[0]) : 0;
                            })
                    }]
                });
                
                // Populate table with units
                let tableHtml = '';
                data.forEach(d => {
                    let metricName = d.key;
                    let value = d.value;
                    
                    // Add appropriate units to metrics
                    if (d.key === 'transactions:') {
                        // Extract the transactions per second value from parentheses
                        const tpsMatch = d.value.toString().match(/\(([0-9.]+) per sec\.\)/);
                        if (tpsMatch && tpsMatch[1]) {
                            value = d.value + ' (' + tpsMatch[1] + ' per sec.)';
                        }
                        metricName = 'Transactions';
                    } 
                    else if (d.key === 'queries:') {
                        // Extract the queries per second value from parentheses
                        const qpsMatch = d.value.toString().match(/\(([0-9.]+) per sec\.\)/);
                        if (qpsMatch && qpsMatch[1]) {
                            value = d.value + ' (' + qpsMatch[1] + ' per sec.)';
                        }
                        metricName = 'Queries';
                    }
                    else if (d.key === 'threads:') metricName = 'Threads';
                    else if (d.key === 'read:') metricName = 'Read Operations';
                    else if (d.key === 'write:') metricName = 'Write Operations';
                    else if (d.key === 'other:') metricName = 'Other Operations';
                    else if (d.key === 'total:') metricName = 'Total Operations';
                    else if (d.key === 'time:') metricName = 'Time (seconds)';
                    else if (d.key === 'min:') metricName = 'Min Latency (ms)';
                    else if (d.key === 'avg:') metricName = 'Avg Latency (ms)';
                    else if (d.key === 'max:') metricName = 'Max Latency (ms)';
                    else if (d.key === '95th:') metricName = '95th Percentile Latency (ms)';
                    
                    tableHtml += '<tr><td>' + metricName + '</td><td>' + value + '</td></tr>';
                });
                document.getElementById(tableId).innerHTML = tableHtml;
            }
        }
    </script>
</body>
</html>
EOF
  echo "Generated HTML report at $OUTPUT_DIR/sysbench_report.html"
}

# Main execution logic
case "$1" in
  install )
    sysbench_install
    ;;
  install-source-el9 )
    sysbench_install_el9
    ;;
  update )
    sysbench_update
    ;;
  cpu )
    adjust_parameters
    sysbench_cpu
    ;;
  mem )
    adjust_parameters
    sysbench_mem
    ;;
  fileio )
    adjust_parameters
    sysbench_fileio
    ;;
  fileio-16k )
    adjust_parameters
    sysbench_fileio 16 seqwr
    ;;
  fileio-64k )
    adjust_parameters
    sysbench_fileio 64 seqwr
    ;;
  fileio-512k )
    adjust_parameters
    sysbench_fileio 512 seqwr
    ;;
  fileio-1m )
    adjust_parameters
    sysbench_fileio 1024 seqwr
    ;;
  fileio-fsync )
    adjust_parameters
    sysbench_fileio "" fsync
    ;;
  fileio-fsync-16k )
    adjust_parameters
    sysbench_fileio 16 fsync
    ;;
  mysql )
    adjust_parameters
    sysbench_mysqloltp
    ;;
  mysqlro )
    adjust_parameters
    sysbench_mysqlro
    ;;
  mysqlinsert )
    adjust_parameters
    sysbench_mysqlinsert
    ;;
  mysqlupdateindex )
    adjust_parameters
    sysbench_mysqlupdateindex
    ;;
  mysqlupdatenonindex )
    adjust_parameters
    sysbench_mysqlupdatenonindex
    ;;
  mysqloltpnew )
    adjust_parameters
    sysbench_mysqloltp_new
    ;;
  mysqlreadonly-new )
    adjust_parameters
    sysbench_mysqlro_new
    ;;
  mysqlwriteonly-new )
    adjust_parameters
    sysbench_mysqlwo_new
    ;;
  mysqlpointselect-new )
    adjust_parameters
    sysbench_mysqlpointselect_new
    ;;
  tools )
    tools_setup
    ;;
  baseinfo )
    baseinfo
    ;;
  mysqlsettings )
    mysqlsettings
    ;;
  --export-html )
    generate_html_report "$2"
    ;;
  all )
    baseinfo
    adjust_parameters
    sysbench_cpu
    sysbench_mem
    sysbench_fileio
    sysbench_fileio 16 seqwr
    sysbench_fileio 64 seqwr
    sysbench_fileio 512 seqwr
    sysbench_fileio 1024 seqwr
    sysbench_fileio "" fsync
    sysbench_fileio 16 fsync
    sysbench_mysqloltp
    sysbench_mysqlro
    sysbench_mysqlinsert
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
      echo "Usage: $0"
      echo "  install"
      echo "  install-source-el9"
      echo "  update"
      echo "  cpu"
      echo "  mem"
      echo "  fileio"
      echo "  fileio-16k"
      echo "  fileio-64k"
      echo "  fileio-512k"
      echo "  fileio-1m"
      echo "  fileio-fsync"
      echo "  fileio-fsync-16k"
      echo "  mysql"
      echo "  mysqlro"
      echo "  mysqlinsert"
      echo "  mysqlupdateindex"
      echo "  mysqlupdatenonindex"
      echo "  mysqloltpnew"
      echo "  mysqlreadonly-new"
      echo "  mysqlwriteonly-new"
      echo "  mysqlpointselect-new"
      echo "  tools"
      echo "  baseinfo"
      echo "  mysqlsettings"
      echo "  --export-html [output_dir]"
      echo
      echo "$0 option [mysql ssl = y/n] [mysqlusername] [mysqlpassword] [mysqldbname]"
      echo "$0 mysql y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlro y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlinsert y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlupdateindex y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlupdatenonindex y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqloltpnew y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlreadonly-new y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlwriteonly-new y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 mysqlpointselect-new y|n mysqlusername mysqlpassword mysqldbname"
      echo "$0 all"
      exit 1
      ;;
esac
exit