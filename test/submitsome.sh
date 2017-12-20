#!/bin/bash

arcproxy  -S dteam  -c validityPeriod=24h -c vomsACvalidityPeriod=24h

touch list_out.$$
ii=0
while [ $ii != 10 ]; do

  arcsub -c hepgrid6.ph.liv.ac.uk  submit.xrsl -o list_out.$$
  #arcsub -c hepgrid10.ph.liv.ac.uk  submit.xrsl -o list_out.$$

  ii=`expr $ii + 1`
done
echo Job Ids in list_out.$$



