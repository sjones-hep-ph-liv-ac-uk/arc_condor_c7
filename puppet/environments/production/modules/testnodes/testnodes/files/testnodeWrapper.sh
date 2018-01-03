#!/bin/bash

MESSAGE=OK

/usr/libexec/condor/scripts/testnode.sh > /dev/null 2>&1
STATUS=$?

if [ $STATUS != 0 ]; then
  MESSAGE=`grep ^[A-Z0-9_][A-Z0-9_]*=$STATUS\$ /usr/libexec/condor/scripts/testnode.sh | head -n 1 | sed -e "s/=.*//"`
  if [[ -z "$MESSAGE" ]]; then
    MESSAGE=ERROR
  fi
fi

if [[ $MESSAGE =~ ^OK$ ]] ; then
  echo "RalNodeOnline = True"
else
  echo "RalNodeOnline = False"
fi
echo "RalNodeOnlineMessage = $MESSAGE"

#if [[ $MESSAGE =~ ^OK$ ]] ; then
#  :
#  else
#    echo "StartJobs = false"
#fi

echo `date`, message $MESSAGE >> /tmp/testnode.status
exit 0
