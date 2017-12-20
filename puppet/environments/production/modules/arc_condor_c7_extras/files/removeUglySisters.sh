#!/bin/bash

exit

cd /var/spool/arc/jobstatus/logs; for f in `~/scripts/listUglySisters.pl |  sed -e "s/Ugly sister - //"`; do rm -f $f; done

