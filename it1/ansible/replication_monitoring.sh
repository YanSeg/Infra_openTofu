#!/bin/bash

LOG_FILE="/var/log/mysql/replication_logfile.log"
MYSQL_USER="root"
MYSQL_PASSWORD="root_password"


timestamp=$(date +"%Y-%m-%d %H:%M:%S")

result=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW SLAVE STATUS \G;" 2>/dev/null)

log_pos=$(echo "$result" | grep  "Exec_Master_Log_Pos:" | awk '{print $2}')
io_running=$(echo "$result" | grep "Slave_IO_Running:" | awk '{print $2}')
sql_running=$(echo "$result" | grep "Slave_SQL_Running:" | awk '{print $2}')


echo "$timestamp - Log_Position: $io_running " >> "$LOG_FILE"
echo "$timestamp - Slave_IO_Running: $io_running " >> "$LOG_FILE"
echo "$timestamp - Slave_SQL_Running: $sql_running " >> "$LOG_FILE"
