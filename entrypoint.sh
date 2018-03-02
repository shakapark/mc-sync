#!/bin/bash
if [ $INIT ]; then
  echo "Starting initialization"
  mc mirror --force --remove $SRC $DST > /dev/null 2>&1
  echo "Initialization done"
else
  while [ true ]; do
    echo "Starting synchronization"
    mc mirror --force --remove $SRC $DST > /dev/null 2>&1
    echo "Synchronization done sleep 60"
    sleep 60
  done
fi
