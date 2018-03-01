#!/bin/bash
  while [ true ]; do
    echo "Starting synchronization"
    mc mirror --force --remove $localdir $bucket > /dev/null 2>&1
    echo "Synchronization done"
    sleep 30
  done
