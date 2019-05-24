#!/usr/bin/ksh93

# Tool Name     : validateEnvironment.ksh
# Author        : Shane Reddy
# Date of birth : 08/20/2012
# Explanation   : Validation check tool. Prepares the environment ready.
# Modifications :
# Dependencies  : None
#
#

_VELog()
{
          echo "validateEnvironment: $*" >> ../logs/validateEnvironment.log
}
# Main
_VERIFYSHELL=`echo $SHELL|awk -F "/" '{print $NF}'`
if [ $_VERIFYSHELL != ksh ]; then
   echo;echo "[FATAL ERROR:]---> SHELL not compatible."
   echo;echo "***IMPORTANT**** Please run all the tools in ksh or ksh93 shells.";echo
   exit 1
fi

_VEFLAG=0
set -A _DIRS 
a=0
for dir in temp bin/functions logs properties lib misc python perl
do
    if [ ! -d ../$dir ]; then
       ((_VEFLAG+=1))
       _DIRS[a]=$dir,
       ((a+=1));
    else
       _VELog `ls ../$dir`
    fi
done

if [ $_VEFLAG -eq 0 ]; then # At this stage the checks will pass at least with warnings.
   if [ ! -f ../misc/runwsadmin.lock ]; then
      _VELog "ATTENTION: Lock file is missing from misc directory."
      touch ../misc/runwsadmin.lock
      cat <<EOF>> ../misc/runwsadmin.lock
# runwsadmin.lock used for preventing multiple executions of the tool runWsadmin.ksh.
# `date`
# Author : Shane Reddy 
#
EOF
      _VELog "RESOLVED: Created lock file runwsadmin.lock under misc directory."
   fi
   _VELog "System details-> `date` `uname` `hostname`"
   _VELog "Running from `pwd`."
   if [ ! -f /usr/bin/ksh93 ]; then
      _VELog "WARNING: Enhanced korn shell not found."
      perl -i -pe 's/ksh93/ksh/g' functions/* 
      _VEFLAG=100
      _VELog "Changed the SHEBANG to ksh shell."
   fi
   [[ `echo $USER` != "root" ]] && { _VELog "WARNING: Non Root user. If WebSphere+All_its_components are installed/running as root, Please run the tools with root or sudo privileges.";_VEFLAG=100;}
   chmod -R 700 functions
   _VELog "RESOLVED: Updated all the tools under functions directory."
   if [ ! -d ../logs/archive ]; then
      _VELog "ATTENTION: Log archive directory not found."
      mkdir ../logs/archive
      _VELog "RESOLVED: Created log archive directory."
   fi
   if [ ! -f ../properties/env.properties ]; then
      _VELog "ATTENTION: Environmental property file not found."
      touch ../properties/env.properties
      cat <<EOF>> ../properties/env.properties
# Environmental properties file.
# `date`
# Author : Shane Reddy
#
FPATH=`pwd`/functions
EOF
      _VELog "RESOLVED: Created env.properties file under properties directory."
   fi
   if [ $_VEFLAG -eq 100 ]; then
      echo "[PASSED:WARNINGS] All checks passed. Tools are ready to be used." | tee -a ../logs/validateEnvironment.log
      exit 2
   fi
   echo "[PASSED:] All checks passed. Tools are ready to be used." | tee -a ../logs/validateEnvironment.log
   exit 0
elif [ $_VEFLAG -gt 0 ]; then
   _FINALLIST=`echo [${_DIRS[@]}]|sed 's/,]/]/g'`
   echo "[FAILED:FATAL] Missing $_FINALLIST folder(s) one level above."
   exit 1
fi
#Niam