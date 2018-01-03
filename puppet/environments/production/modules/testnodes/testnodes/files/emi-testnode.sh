#!/bin/sh
 
#  set to 1 for debug output 
# now checks environment so can, e.g., run manually as 'env DEBUG=1 ./testnode.sh'
if [ -z $DEBUG ]
  then  DEBUG=0
fi

SUDO=sudo

# return codes
ROOT_NOT_WRITABLE=64
HOME_NOT_WRITABLE=65
DATA_NOT_WRITABLE=66
EXP_SOFT_NOT_MOUNTED=67
ROOT_FULL=68
HOME_FULL=69
SMART_FAILURE=71
YAIM_OUTDATED=72
RPC_STATD_STOPPED=73
KERNEL_VERSION_MISMATCH=74
DEV_NULL_REGULAR_FILE=75
CVMFS_STACKTRACE=77
CVMFS_BROKE=78
AUTOMOUNT_SUCKS=79
DATA_FULLISH=80
DATA2_FULLISH=81
NO_HOME_DIRS=82
TEST_ERROR=83
RPM_VERSION_MISMATCH84=84
RPM_VERSION_MISMATCH85=85
RPM_VERSION_MISMATCH86=86
RPM_VERSION_MISMATCH87=87

# Test error
if [ -f /tmp/TEST_ERROR ] 
then exit $TEST_ERROR
elif [ $DEBUG -eq 1 ]; then /bin/echo "TEST_ERROR did not occur"
fi

# has CVMFS had a wobbly (check for stacktrace file)
if $SUDO /bin/ls /data2/var/cache/cvmfs2/*/stacktrace 2>&1 | grep -v "No such"
then exit $CVMFS_STACKTRACE
elif [ $DEBUG -eq 1 ]; then /bin/echo "CVMFS does not appear to have crashed (no stacktrace files)"
fi

# or does CVMFS think it has a problem
PROBE_COMMAND="cvmfs_config probe"
if $PROBE_COMMAND | grep -i "FAILED"
then exit $CVMFS_BROKE
elif [ $DEBUG -eq 1 ]; then /bin/echo "service cvmfs probe does not indicate a problem"
fi

# Is automount playing up (can't cd to a cvmfs repo)?
for repo in atlas.cern.ch atlas-condb.cern.ch lhcb.cern.ch t2k.egi.eu
do
	if ! cd /cvmfs/$repo
	then
		exit $AUTOMOUNT_SUCKS
	fi
done

# rpc.statd process running?
if ! /bin/ps axco command | grep -q rpc.statd
then exit $RPC_STATD_STOPPED
elif [ $DEBUG -eq 1 ]; then /bin/echo "rpc.statd is running"
fi

# / partition writable?
if ! /bin/touch /tmp/.testnode
then exit $ROOT_NOT_WRITABLE
elif [ $DEBUG -eq 1 ]; then /bin/echo "touch /tmp/.testnode succeeded"
fi
rm /tmp/.testnode

# /home partition writable?
if ! /bin/touch /home/.testnode
then exit $HOME_NOT_WRITABLE
elif [ $DEBUG -eq 1 ]; then /bin/echo "touch /home/.testnode succeeded"
fi
rm /home/.testnode

# At least a few VO users have home dirs
D=`ls -d /home/[a-z]*001 | wc -l`
if [ $D -lt 5 ]
then exit $NO_HOME_DIRS
elif [ $DEBUG -eq 1 ]; then /bin/echo "At least a few VO users have home dirs"
fi

# /data partition writable?
if ! /bin/touch /data/.testnode
then exit $DATA_NOT_WRITABLE
elif [ $DEBUG -eq 1 ]; then /bin/echo "touch /data/.testnode succeeded"
fi
rm /data/.testnode

# /data2 partition writable?
if ! /bin/touch /data2/.testnode
then exit $DATA_NOT_WRITABLE
elif [ $DEBUG -eq 1 ]; then /bin/echo "touch /data2/.testnode succeeded"
fi
rm -f /data2/.testnode

# /dev/null still character device file and not a regular file?
if ! ls -l /dev/null | /bin/grep -q \^c
then exit $DEV_NULL_REGULAR_FILE
elif [ $DEBUG -eq 1 ]; then /bin/echo "/dev/null is a character device file"
fi

# disk check. 0 is ok, 32 indicates disk is ok, but some attributes have passed threshold in past
for disk in sda sdb
do
        $SUDO /usr/sbin/smartctl -H /dev/$disk &> /dev/null
        if ! [ $? -eq 0 -o $? -eq 32 ]
                then exit $SMART_FAILURE
        elif [ $DEBUG -eq 1 ]; then /bin/echo "smartctl -H /dev/$disk passed"
        fi
done

# exp_soft_sl5 mounted?
if ! /bin/mount -t nfs -l | /bin/awk '{print $3}' | /bin/grep -q \^/opt/exp_soft_sl5\$
then exit $EXP_SOFT_NOT_MOUNTED
elif [ $DEBUG -eq 1 ]; then /bin/echo "/opt/exp_soft_sl5 mounted"
fi

# space free on /?
if /bin/df / | /bin/awk '{print $4}' | /bin/grep -q \^0\$
then exit $ROOT_FULL
elif [ $DEBUG -eq 1 ]; then /bin/echo "Space free on / partition"
fi

# space free on /data?
if /bin/df /data | /bin/awk '{print $4}' | /bin/grep \^0\$
then exit $HOME_FULL
elif [ $DEBUG -eq 1 ]; then /bin/echo "Space free on /data partition"
fi

# at least 90% is needed on data
if df | perl -ne ' if (/\/data$/) { /^.*\s([0-9]+)\%/; if ($1 > 90) { print("data fs getting full, percent used is $1\n");exit(0); } exit (1)} '
then exit $DATA_FULLISH
elif [ $DEBUG -eq 1 ]; then /bin/echo "At least 10% space free on /data partition"
fi

# at least 90% is needed on data2
if df | perl -ne ' if (/\/data2$/) { /^.*\s([0-9]+)\%/; if ($1 > 90) { print("data2 fs getting full, percent used is $1\n");exit(0); } exit (1)} '
then exit $DATA2_FULLISH
elif [ $DEBUG -eq 1 ]; then /bin/echo "At least 10% space free on /data2 partition"
fi

if /bin/uname -r | /bin/grep -qv \^3.10.0-693.2.1.el7.x86_64\$
then
  if /bin/uname -r | /bin/grep -qv \^3.10.0-693.2.2.el7.x86_64\$
  then
    if /bin/uname -r | /bin/grep -qv \^3.10.0-693.5.2.el7.x86_64\$
    then
      exit $KERNEL_VERSION_MISMATCH
    fi
  fi
fi

if [ $DEBUG -eq 1 ]; then /bin/echo "Correct version of kernel running"; fi

# lcg-CA
if rpm -q lcg-CA | /bin/grep -v \^lcg-CA-1.88-1.noarch\$
then
  exit $RPM_VERSION_MISMATCH84
fi
if [ $DEBUG -eq 1 ]; then /bin/echo "Correct version of lcg-CA installed"; fi

# canl-c
if rpm -q canl-c | /bin/grep -v canl-c-2.1.8-1
  then
    exit $RPM_VERSION_MISMATCH85
fi
if [ $DEBUG -eq 1 ]; then /bin/echo "Correct version of canl-c installed"; fi

#
# emi-version
#
if rpm -q condor | /bin/grep -v \^condor-8
then
  if rpm -q emi-version | /bin/grep -v \^emi-version-3.15.0-1.el6.x86_64
  then
    exit $RPM_VERSION_MISMATCH86
  fi
fi
if [ $DEBUG -eq 1 ]; then /bin/echo "Correct version of emi-version or condor installed"; fi

#
# fetch-crl version
#
if rpm -q fetch-crl | /bin/grep -v \^fetch-crl-3.0.19-1
then
  exit $RPM_VERSION_MISMATCH87
fi
if [ $DEBUG -eq 1 ]; then /bin/echo "Correct version of fetch-crl installed"; fi

# No Yaim check

exit 0
