#!/bin/bash

function backup() {
  echo "Starting Backup"

  DATE=$(date -d "$RETENTION days ago" +"%d-%m-%Y")
  mc rm --recursive --force $DST/$DATE

  DATE=$(date +"%d-%m-%Y")
  mc mb $DST/$DATE
  echo $?

  BUCKETS=$(mc --json ls $SRC | grep -Eo '"key":.*?[^\\]",'|awk -F':' '{print $2}' | cut -d \" -f2 | cut -d / -f1 | tr " " "\n")
  for BUCKET in $BUCKETS
  do
    mc cp -r $SRC/$BUCKET $DST/$DATE
    if [ $? != 0 ]
    then
      exit 1
    fi
  done

  echo "Backup Done"

  exit 0
}

function init() {
  echo "Starting initialization"
  mc mirror --force --remove $SRC $DST > /dev/null 2>&1
  echo "Initialization done"
}

function sync() {
  while [ true ]; do
    echo "Starting synchronization"
    mc mirror --force --remove $SRC $DST > /dev/null 2>&1
    echo "Synchronization done sleep 60"
    sleep 60
  done

}

case $TYPE in
        backup)
            backup
            ;;

        init)
            init
            ;;

        sync)
            sync
            ;;

        *)
            echo "TYPE: {backup|init|sync}"
            exit 1
esac
