#!/bin/bash

SWAP=`free | grep Swap  | sed -e 's/Swap:\s*//' -e 's/\s\s*.*//'`
SWAPLIMIT=$(($SWAP * 3 / 4 ))
SWAPLIMIT=$(($SWAP / 2 ))
SWAPUSED=`free | grep Swap  | sed -e 's/Swap:\s*[0-9][0-9]*\s*//' -e 's/\s\s*[0-9][0-9]*//'`
#echo $SWAP $SWAPLIMIT $SWAPUSED

if  [ -n $SWAPUSED ] && [ -n $SWAPLIMIT ] ; then
  if [ $SWAPUSED -gt $SWAPLIMIT ]; then
    #echo service numad restart
    service numad restart
  fi
fi


#[root@comp504 scripts]# free
#             total       used       free     shared    buffers     cached
#Mem:      24595376    8320492   16274884          0     171356    2506556
#-/+ buffers/cache:    5642580   18952796
#Swap:     25165820      39880   25125940
#

