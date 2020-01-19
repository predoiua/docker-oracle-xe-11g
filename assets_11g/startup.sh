#!/bin/bash

OR=/u01
export ORACLE_HOME=${OR}/app/oracle/product/11.2.0/db_1
LISTENER_ORA=${ORACLE_HOME}/network/admin/listener.ora
TNSNAMES_ORA=${ORACLE_HOME}/network/admin/tnsnames.ora

export PATH=${PATH}:${ORACLE_HOME}/bin

cp "${LISTENER_ORA}.tmpl" "$LISTENER_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENER_ORA}" &&
sed -i "s/%port%/1521/g" "${LISTENER_ORA}" &&
cp "${TNSNAMES_ORA}.tmpl" "$TNSNAMES_ORA" &&
sed -i "s/%hostname%/$HOSTNAME/g" "${TNSNAMES_ORA}" &&
sed -i "s/%port%/1521/g" "${TNSNAMES_ORA}" &&

service oracle restart


echo "Execute custom init script"
for f in /docker-entrypoint-initdb.d/*; do
  [ -f "$f" ] || continue
  case "$f" in
    *.sh)     echo "$0: running $f"; . "$f" ;;
    *.sql)    echo "$0: running $f"; echo "exit" | sqlplus "system/oracle" @"$f"; echo ;;
    *)        echo "$0: ignoring $f" ;;
  esac
  echo
done
