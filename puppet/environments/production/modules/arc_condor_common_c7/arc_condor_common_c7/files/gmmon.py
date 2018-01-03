#!/usr/bin/python

import calendar
import sys
import os
import time
import smtplib
import logging

if (len(sys.argv) == 2):
  limit = int(sys.argv[1])
else:
  limit = 600

# Maybe put logging in some time
logging.basicConfig(level=logging.DEBUG,
  format='%(asctime)s %(levelname)s %(message)s',
  filename="/var/log/gmmon.log",
  filemode='a')

# Email details
smtpserver = 'hep.ph.liv.ac.uk'
recipients = ['sysadmin@hep.ph.liv.ac.uk','sjones@hep.ph.liv.ac.uk']
sender = 'root@hepgrid8.ph.liv.ac.uk'
msgheader = "From: root@hepgrid8.ph.liv.ac.uk\r\nTo: sysadmin@hep.ph.liv.ac.uk\r\nSubject: Grid-manager Monitor\r\n\r\n"

ageOfGmHeartbeat = os.path.getmtime('/var/spool/arc/jobstatus/gm-heartbeat')
timeNow = calendar.timegm(time.gmtime())

if (timeNow > ageOfGmHeartbeat + limit):
  logging.info("The gm-heartbeat file is getting old. Restarting the a-rex service on hepgrid2")

  session = smtplib.SMTP(smtpserver)
  smtpresult = session.sendmail(sender, recipients, msgheader + "The gm-heartbeat file is getting old. Restarting the a-rex service on hepgrid2\n")
  session.quit()

  os.system("/etc/init.d/a-rex restart")

else:
  logging.info("Happy state for gm-heartbeat on hepgrid2" )

