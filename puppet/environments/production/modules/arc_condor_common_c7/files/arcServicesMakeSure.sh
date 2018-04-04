#!/bin/bash

export _SYSTEMCTL_SKIP_REDIRECT=1

doStart=0
service nordugrid-arc-slapd status
if [ $? != 0 ]; then
  doStart=1
fi

service nordugrid-arc-bdii status
if [ $? != 0 ]; then
  doStart=1
fi

if [ $doStart == 1 ]; then

  # Stop them all
  services=`chkconfig --list 2>&1 | grep nordu|sed -e "s/\t.*//"`

  for s in $services; do
    service $s stop
  done

  for pid in `ps -ef | grep bdii | grep -v grep | sed -e "s/root\s*//" -e "s/\s.*//"`; do
    kill -9 $pid;
  done

  find -L /var/lock -name "nordu*" -exec rm -f {} \;
  find -L /run -name "slapd.pid"  -exec rm -f {} \;
  find -L /run -name "bdii-update.pid" -exec rm -f {} \;

  for s in $services; do
    service $s stop
  done

  # Start them all
  service nordugrid-arc-slapd start
  service nordugrid-arc-bdii start
  service nordugrid-arc-inforeg start

fi

