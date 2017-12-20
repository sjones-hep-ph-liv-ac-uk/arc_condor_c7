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

"""Usage: default_rte_plugin.py <status> <control dir> <jobid> <runtime environment>

Authplugin for PREPARING STATE

Example:

  authplugin="PREPARING timeout=60,onfailure=pass,onsuccess=pass /usr/local/bin/default_rte_plugin.py %S %C %I <rte>"

"""

def ExitError(msg,code):
    """Print error message and exit"""
    from sys import exit
    print(msg)
    exit(code)

def SetDefaultRTE(control_dir, jobid, default_rte):

    from os.path import isfile

    desc_file = '%s/job.%s.description' %(control_dir,jobid)

    if not isfile(desc_file):
       ExitError("No such description file: %s"%desc_file,1)

    f = open(desc_file)
    desc = f.read()
    f.close()

    if default_rte not in desc:
      if '<esadl:ActivityDescription' in desc:
        lines = desc.split('\n')
        with open(desc_file, "w") as myfile:
          for line in lines:
            myfile.write( line + '\n')
            if '<Resources>' in line:
              myfile.write( '   <RuntimeEnvironment>\n')
              myfile.write( '     <Name>' + default_rte + '</Name>\n')
              myfile.write( '   </RuntimeEnvironment>\n')
      else:
        if '<jsdl:JobDefinition' not in desc:
          with open(desc_file, "a") as myfile:
            myfile.write("( runtimeenvironment = \"" + default_rte + "\" )")

    return 0

def main():
    """Main"""

    import sys

    # Parse arguments

    if len(sys.argv) == 5:
        (exe, status, control_dir, jobid, default_rte) = sys.argv
    else:
        ExitError("Wrong number of arguments\n"+__doc__,1)

    if status == "PREPARING":
        SetDefaultRTE(control_dir, jobid, default_rte)
        sys.exit(0)

    sys.exit(1)

if __name__ == "__main__":
    main()

