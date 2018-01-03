#!/usr/bin/python
# Copyright 2014 Science and Technology Facilities Council
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import re
from os.path import isfile
import shutil
import datetime
import time
import os


"""Usage: scaling_factors_plugin.py <status> <control dir> <jobid>

Authplugin for FINISHING STATE

Example:

  authplugin="FINISHING timeout=60,onfailure=pass,onsuccess=pass /usr/local/bin/scaling_factors_plugin.py %S %C %I"

"""

def ExitError(msg,code):
    """Print error message and exit"""
    from sys import exit
    print(msg)
    exit(code)

def GetScalingFactor(control_dir, jobid):

    errors_file = '%s/job.%s.errors' %(control_dir,jobid)

    if not isfile(errors_file):
       ExitError("No such errors file: %s"%errors_file,1)

    f = open(errors_file)
    errors = f.read()
    f.close()

    scaling = -1

    m = re.search('MATCH_EXP_MachineRalScaling = \"([\dE\+\-\.]+)\"', errors)
    if m:
       scaling = float(m.group(1))

    return scaling


def SetScaledTimes(control_dir, jobid):

    scaling_factor = GetScalingFactor(control_dir, jobid)

    diag_file = '%s/job.%s.diag' %(control_dir,jobid)


    if not isfile(diag_file):
       ExitError("No such errors file: %s"%diag_file,1)

    f = open(diag_file)
    lines = f.readlines()
    f.close()

    newlines = []

    types = ['WallTime=', 'UserTime=', 'KernelTime=']

    for line in lines:
       for type in types:
          if type in line and scaling_factor > 0:
             m = re.search('=(\d+)s', line)
             if m:
                scaled_time = int(float(m.group(1))*scaling_factor)
                line = type + str(scaled_time) + 's\n'

       newlines.append(line)

    fw = open(diag_file, "w")
    fw.writelines(newlines)
    fw.close()
    # Save a copy. Use this for the DAPDUMP analyser.
    #tstamp = datetime.datetime.fromtimestamp(time.time()).strftime('%Y%m%d%H%M%S')
    #dest = '/var/log/arc/diagfiles/' + tstamp + '_' + os.path.basename(diag_file)
    #shutil.copy2(diag_file, dest)

    return 0


def main():
    """Main"""

    import sys

    # Parse arguments

    if len(sys.argv) == 4:
        (exe, status, control_dir, jobid) = sys.argv
    else:
        ExitError("Wrong number of arguments\n"+__doc__,1)

    if status == "FINISHING":
        SetScaledTimes(control_dir, jobid)
        sys.exit(0)

    sys.exit(1)

if __name__ == "__main__":
    main()

