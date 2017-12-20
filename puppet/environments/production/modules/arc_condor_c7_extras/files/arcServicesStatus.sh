#!/bin/bash

export _SYSTEMCTL_SKIP_REDIRECT=1

services=`chkconfig --list 2>&1 | grep nordu|sed -e "s/\t.*//"`

for s in $services; do
  service $s status
done

