#!/bin/sh

DEBUG=1
CVMFS_STACKTRACE=77
CVMFS_BROKE=78
AUTOMOUNT_SUCKS=79
echo -n Start:" " ; date
# has CVMFS had a wobbly (check for stacktrace file)
if  /bin/ls /data2/var/cache/cvmfs2/*/stacktrace 2>&1 | grep -v "No such"
then echo CVMFS_STACKTRACE $CVMFS_STACKTRACE
elif [ $DEBUG -eq 1 ]; then /bin/echo "CVMFS does not appear to have crashed (no stacktrace files)"
fi

# or does CVMFS think it has a problem
PROBE_COMMAND="cvmfs_config probe"
if $PROBE_COMMAND | grep -i "FAILED"
then echo CVMFS_BROKE $CVMFS_BROKE
elif [ $DEBUG -eq 1 ]; then /bin/echo "service cvmfs probe does not indicate a problem"
fi

# Is automount playing up (can't cd to a cvmfs repo)?
for repo in atlas.cern.ch atlas-condb.cern.ch lhcb.cern.ch t2k.egi.eu
do
        if ! cd /cvmfs/$repo
        then
                echo AUTOMOUNT_SUCKS $AUTOMOUNT_SUCKS
        fi
        ls -lrt | head -n 2 | tail -n 1
done
echo -n End:" " ; date



