#!/bin/bash
#
# Raise priority of users of MC jobs
PRIORITY=1

for mcu in `condor_userprio -flat | grep mcore | sed -e "s/ .*//"`; do 
  condor_userprio -setfactor $mcu $PRIORITY
done


