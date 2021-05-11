#!/bin/bash
# Based on script created by camilb's (github.com/camilb)
# Source: https://github.com/camilb/kube-mysqldump-cron/blob/master/Docker/dump.sh

DB_USER=${MYSQL_ENV_DB_USER}
DB_PASS=${MYSQL_ENV_DB_PASS}
DB_HOST=${MYSQL_ENV_DB_HOST}

if [[ ${DB_USER} == "" ]]; then
    echo "Missing DB_USER env variable"
    exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
    echo "Missing DB_PASS env variable"
    exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
    echo "Missing DB_HOST env variable"
    exit 1
fi

databases=`mysql --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases;
do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]];
  then
    echo "Dumping database: $db"
    mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --databases $db > /mysqldump/$db-"$(date '+%Y%m%d%H%M%S')".sql
  fi
done
