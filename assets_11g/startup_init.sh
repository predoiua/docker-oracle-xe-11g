#!/bin/bash

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
