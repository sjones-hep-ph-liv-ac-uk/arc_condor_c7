#!/bin/bash

export _SYSTEMCTL_SKIP_REDIRECT=1

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

for s in $services; do
  service $s status
done

