#!/bin/bash

# Send the accounting over with our custom jura (for test)
/usr/libexec/arc/jura.custom /var/spool/arc/jobstatus &>> /var/log/arc/jura.log 

# Get rid of the ugly sisters (i.e. start records, associated with sent records)
/root/scripts/removeUglySisters.sh 

