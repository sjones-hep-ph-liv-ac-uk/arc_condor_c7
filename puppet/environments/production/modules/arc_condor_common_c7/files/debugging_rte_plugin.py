#!/usr/bin/python

# This copies the files containing useful output from completed jobs into a directory 

import shutil

"""Usage: debugging_rte_plugin.py <status> <control dir> <jobid>

Authplugin for FINISHED STATE

Example:

  authplugin="FINISHED timeout=60,onfailure=pass,onsuccess=pass /usr/local/bin/debugging_rte_plugin.py %S %C %I"

"""

def ExitError(msg,code):
    """Print error message and exit"""
    from sys import exit
    print(msg)
    exit(code)

def ArcDebuggingL(control_dir, jobid):

    from os.path import isfile
   
    try:
        m = open("/var/spool/arc/debugging/msgs", 'a') 
    except IOError ,  err:
        print err.errno 
        print err.strerror 


    local_file = '%s/job.%s.local' %(control_dir,jobid)
    grami_file = '%s/job.%s.grami' %(control_dir,jobid)

    if not isfile(local_file):
       ExitError("No such description file: %s"%local_file,1)

    if not isfile(grami_file):
       ExitError("No such description file: %s"%grami_file,1)

    lf = open(local_file)
    local = lf.read()
    lf.close()

    if 'Organic Units' in local or 'stephen jones' in local:
        shutil.copy2(grami_file, '/var/spool/arc/debugging')

        f = open(grami_file)
        grami = f.readlines()
        f.close()
    
        for line in grami:
            m.write(line)
            if 'joboption_directory' in line:
               comment = line[line.find("'")+1:line.find("'",line.find("'")+1)]+'.comment'
               shutil.copy2(comment, '/var/spool/arc/debugging')
            if 'joboption_stdout' in line:
               mystdout = line[line.find("'")+1:line.find("'",line.find("'")+1)]
               m.write("Try Copy mystdout - " + mystdout + "\n")
               if isfile(mystdout):
                 m.write("Copy mystdout - " + mystdout + "\n")
                 shutil.copy2(mystdout, '/var/spool/arc/debugging')
               else:
                 m.write("mystdout gone - " + mystdout + "\n")
            if 'joboption_stderr' in line:
               mystderr = line[line.find("'")+1:line.find("'",line.find("'")+1)]
               m.write("Try Copy mystderr - " + mystderr + "\n")
               if isfile(mystderr):
                 m.write("Copy mystderr - " + mystderr + "\n")
                 shutil.copy2(mystderr, '/var/spool/arc/debugging')
               else:
                 m.write("mystderr gone - " + mystderr + "\n")

    close(m)
    return 0

def main():
    """Main"""

    import sys

    # Parse arguments

    if len(sys.argv) == 4:
        (exe, status, control_dir, jobid) = sys.argv
    else:
        ExitError("Wrong number of arguments\n",1)

    if status == "FINISHED":
       ArcDebuggingL(control_dir, jobid)
       sys.exit(0)

    sys.exit(1)

if __name__ == "__main__":
    main()

