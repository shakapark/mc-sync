#!/bin/bash

function backup() {
  echo "Starting Backup"

  DATE=$(date +"%d-%m-%Y")
  mc mb $DST/$DATE

  BUCKETS=$(mc --json ls $SRC | grep -Eo '"key":.*?[^\\]",'|awk -F':' '{print $2}' | cut -d \" -f2 | cut -d / -f1 | tr " " "\n")
  for BUCKET in $BUCKETS
  do
    mc cp -r $SRC/$BUCKET $DST/$DATE
  done

  DATE=$(date -d "$RETENTION days ago" +"%d-%m-%Y")
  mc rm --recursive --force $DST/$DATE

  echo "Backup Done"
}

function init() {
  echo "Starting initialization"
  mc mirror --overwrite --remove $SRC $DST 
  echo "Initialization done"
}

function sync() {
  while [ true ]; do
    echo "Starting synchronization"
    mc mirror --remove $SRC $DST
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
