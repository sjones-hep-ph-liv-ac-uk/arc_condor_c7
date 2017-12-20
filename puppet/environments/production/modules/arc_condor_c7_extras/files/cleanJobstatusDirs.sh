#!/bin/bash

MAXAGE=21
echo `date` cleanJobstatusDirs.sh starts with maxage of $MAXAGE days
fname=/opt/jobstatus_archive/jobstatus_"$(date +%Y%m%d%H%M%S)".tar
sleep 1

if [ ! -d /opt/jobstatus_archive ]; then
  mkdir /opt/jobstatus_archive
  if [ $? != 0 ]; then
    echo Some kind of problem so I cannot make the jobstatus_archive dir
    exit 1
  fi
fi

cd /var/spool/arc/jobstatus
if [ $? != 0 ]; then
  echo Some problem getting to the jobstatus dir so I am bailing out
  exit 1
fi

# Back up all the jobstatus files older than MAXAGE
tmpListOfOldFiles=$(mktemp /tmp/jobstatus_archive_files.XXXXXX)
find /var/spool/arc/jobstatus  -mtime +$MAXAGE -type f  > $tmpListOfOldFiles
tar -cf $fname -T $tmpListOfOldFiles
gzip $fname 

# Delete all the jobstatus files older than MAXAGE
for f in `cat $tmpListOfOldFiles`; do 
  echo Deleting empty file $f
  rm -f $f
done

tmpListOfOldDirs=$(mktemp /tmp/jobstatus_archive_dirs.XXXXXX)
for f in `cat $tmpListOfOldFiles`; do echo `dirname $f`; done | sort -n | uniq > $tmpListOfOldDirs

for d in `cat $tmpListOfOldDirs`; do
  ls -1 $d | wc -l | grep -q "^0$"
  if [ $? == 0 ]; then
    echo Deleting empty dir $d
    rmdir $d
  fi
done

# Clean the delegations of empty dirs more than 90 days old
find /var/spool/arc/jobstatus/delegations/ -depth -type d -empty -mtime +90 -delete

# Clean the urs
find /var/urs -depth -type f -mtime +90 -delete

rm $tmpListOfOldFiles
rm $tmpListOfOldDirs
