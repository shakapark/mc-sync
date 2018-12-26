#!/bin/bash

function backupMinio() {
  echo "Starting Backup"

  DATE=$(date -d "$RETENTION days ago" +"%d-%m-%Y")
  mc rm --recursive --force $DST/$DATE

  DATE=$(date +"%d-%m-%Y")
  mc mb $DST/$DATE
  echo $?

  BUCKETS=($(mc --json ls $SRC | grep -Eo '"key":.*?[^\\]",'|awk -F':' '{print $2}' | cut -d \" -f2 )) #| tr "/ " "\n"))
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

function backupAWS() {
  echo "Starting Backup"

  echo "Remove old folder"
  DATE=$(date -d "$RETENTION days ago" +"%d-%m-%Y")
  mc rm --recursive --force $DST/$DATE

  DATE=$(date +"%d-%m-%Y")
  BUCKETS=($(mc --json ls $SRC | grep -Eo '"key":.*?[^\\]",'|awk -F':' '{print $2}' | cut -d \" -f2 )) #| tr "/ " "\n"))
  echo $BUCKETS
  for BUCKET in $BUCKETS
  do
    echo $BUCKET
    mc cp -r $SRC/$BUCKET $DST/$DATE
    if [ $? != 0 ]
    then
      exit 1
    fi
  done

  echo "Backup Done"

  exit 0  
  sleep 600
}

function init() {
  echo "Starting initialization"
  mc mirror --overwrite --remove $SRC $DST
  echo "Initialization done"
}

function sync() {
  while [ true ]; do
    echo "Starting synchronization"
    mc mirror --overwrite --remove $SRC $DST
    echo "Synchronization done sleep 60"
    sleep 60
  done

}

function purge() {
  echo "Starting Purge"

  if [ "$BUCKETS" == "" ]; then
    echo "BUCKETS is empty"
    TAB=($(mc --json ls $SRC | grep -Eo '"key":.*?[^\\]",'|awk -F':' '{print $2}' | cut -d \" -f2 | tr "/ " "\n"))
  else
    echo "BUCKETS is not empty"
    TAB=($(echo $BUCKETS | tr ',' "\n"))
  fi

  for BUCKET in "${TAB[@]}"
  do
    echo $BUCKET
    mc rm --recursive --force --older-than=$RETENTION $SRC/$BUCKET/
  done

  echo "Purge Done"

  exit 0
}

case $TYPE in
        backupMinio)
            backupMinio
            ;;
        backupAWS)
            backupAWS
            ;;

        init)
            init
            ;;

        sync)
            sync
            ;;

        purge)
            purge
            ;;

        *)
            echo "TYPE: {backupMinio|backupAWS|init|sync|purge}"
            exit 1
esac
