#!/usr/bin/ksh93

# Script Name   : run.ksh.
# Date of birth : 08/11/2012. # 08.11.12v is the initial version.
# Version       : 08.12.12v
#                 The version is obtained by the latest date of the tool in working condition.
# Author        : Shane Reddy.
# Explanation   : Universal execution tool. Tested in AIX, Need testing in other flavors.
#                 WebSphere mentioned here is WebSphere Application Server and IBM HTTP Server.
#                 Tool checks for the WebSphere product.
#
# Dependencies  :
# Modifications :
#

# Contact me    : r2d2c3p0
#
#

# Global variables
#---------------------------------------------------------------------------------------------------------------------------------------------------

function SAFE_EXIT
{
         LOGERROR "SIGNAL INTERRUPT received."
         LOGERROR "Safe exiting."
         trap "" 2
}
trap "SAFE_EXIT" 2

LANG_FLAG=0
INFOFILE=../logs/systemout.log
ERRFILE=../logs/systemerr.log
PY_DIR=../python

# Functions
#----------------------------------------------------------------------------------------------------------------------------------------------------

function USAGE
{
         echo
         echo "  Usage: run.ksh [-file|-f] [-info|-i] [-help|-h] [-version|-v] [-interactive] {-nri}"
         echo
         echo "  Where:"
         echo "       -file or -f = Input filename. This argument needs to be followed by a filename."
         echo "                     This tool is designed for websphere installation, administration, deployment and uninstallation purpose."
         echo "                     Supported languages - JACL and Jython/Python."
         echo "                     Use option <-nri> = Non-Root installation to suppress root execution, Where: The WebSphere is installed by non-root user."
         echo "                     Enter option -nri at the very end."
         echo "       -info or -i = Prints basic information."
         echo "       -help or -h = Prints usage and available input arguments."
         echo "       -version or -v = Prints the current version."
         echo "       -interactive = Invokes interactive mode/shell. Enter 'q' to quit the mode."
         echo
         exit 1
}

function PARSEFILE
{
         if [ ! -f $PY_DIR/$IPTFILE ]; then
            LOGERROR "File $IPTFILE is not found under python."
            exit 1
         fi
         IPTFILEX=$PY_DIR/$IPTFILE
         GETEXT=`echo $IPTFILE |awk -F . '{print NF}'`
         EXTENTION=`echo $IPTFILE|cut -d '.' -f$GETEXT`
         case $EXTENTION in
                           python|py|jy|jython)
                                              LANG_FLAG=1
                                              ;;
                                      jacl|tcl)
                                              LANG_FLAG=2
                                              ;;
                                             *)
                                              LOGWAR "Input file does not have recommended file extention. [$EXTENTION]"
                                              ;;
         esac
         egrep 'def|proc' $IPTFILEX > /dev/null 2>&1
         if [ $? -ne 0 ]; then
            LOGERROR "Contents of $IPTFILE not supported. Refer usage[-h]"
            exit 1
         fi
}

function LOGINFO
{
         echo "$DATE | INFO: $*" |tee -a $INFOFILE
}

function VALIDATEFILE
{
         awk '!x[$0]++' $PROPFILE > $PROPFILE\_$$
         mv $PROPFILE\_$$ $PROPFILE
         set -A KV_ARGS
         KV_ARGS[0]="[ Key(s) missing value(s):"
         kv_flag=0
         y=1
         for KVPAIR in `cat $PROPFILE|grep -v ^#`
         do
             key=`echo $KVPAIR|cut -d"=" -f1`
             value=`echo $KVPAIR|cut -d"=" -f2`
             [ -z "$value" ] && { KV_ARGS[y]=$key ; ((y+=1)); kv_flag=1; }
         done
         z=${#KV_ARGS[@]}
         ((z+=1))
         KV_ARGS[$z]="]"
         #[ -z `grep  '[^[:alnum:] _-./\#=\$]' $PROPFILE` ] || { LOGERROR "$PROPFILE validation failed. Special characters found." ; exit 1 ; }
         if [ $kv_flag -ne 0 ]; then
            LOGERROR "Key-Value. $PROPFILE validation failed."
            echo $DATE ${KV_ARGS[@]}|tee -a $ERRFILE
            exit 1
         else
            LOGINFO "$PROPFILE validation passed."
         fi
}

function LOGERROR
{
         echo "$DATE | ERROR: $*" |tee -a $INFOFILE
         echo "$DATE | ERROR: $*" >> $ERRFILE
}

function YOELREY
{
         shift `expr $# - 1`
         ROOT_FLAG=$1
         if [ $ROOT_FLAG == "-nri" ]; then
            LOGWAR "Suppressing root execution, Reason: Non-Root WebSphere installation maybe..???"
         else
            if [ $USER != "root" ]; then
               LOGERROR "[$USER] Root/Sudo privileges are required to run this tool."
               exit 1
            fi
         fi
}

function LOGWAR
{
         echo "$DATE | WARNING: $*" |tee -a $INFOFILE
         echo "$DATE | WARNING: $*" >> $ERRFILE
}

function LOGCLEAN
{
         #LOG_SIZE=`ls -lrt $INFOFILE |awk '{print $5}'`
         #echo $LOG_SIZE
         find ../logs \
            -type f \
            -name '*.log'\
            -print \
            | while read file
              do
                SIZE=`du -m $file|awk '{print $1}'`
                if [ $SIZE -gt 5 ]; then
                   LOGWAR "$file is over the limit."
                   mv $file $file\_`date +"%d%m%Y" `
                   LOGINFO "$file is rotated."
                fi
              done
}

function MAIN
{
         PYFILE=$PY_DIR/$2
         shift 2
         REST=$*
         if [ $LANG_FLAG -eq 2 ]; then
            CMD="sudo $WSADMIN_PATH/wsadmin.sh -lang jacl -f $PYFILE $REST"
         else
            CMD="sudo $WSADMIN_PATH/wsadmin.sh -lang jython -f $PYFILE $REST"
         fi
         $CMD | egrep -v "SOAP connector;|argv variable"|tee -a $INFOFILE
}

function GETINOPT
{
         set -A OPTIONS_ARGS
         OPTIONS_ARGS[0]="[Input arguments:"
         x=1
         for a in $*; do
             if [ $x -eq $# ]; then
                OPTIONS_ARGS[x]=$a]
             else
                OPTIONS_ARGS[x]=$a,
             fi
             ((x+=1))
         done
         echo ${OPTIONS_ARGS[@]}|tee -a $INFOFILE
}

# Main
#-----------------------------------------------------------------------------------------------------------------------------------------------------

function MAIN_INT
{
         echo >> $INFOFILE
         echo ">" >> $INFOFILE
         echo >> $INFOFILE
         # If you are running on other flavors adjust the below ksh version accordingly.
         LOGINFO "Running the _main_ initialization."
         echo "Filename - run.ksh"|tee -a $INFOFILE
         echo "ksh version - ${.sh.version}"|tee -a $INFOFILE
         echo "OS flavor - `uname -a`"|tee -a $INFOFILE
         print "run: ${.sh.name}[ ${.sh.subscript}]=${.sh.value}"|tee -a $INFOFILE
         echo "$USER"|tee -a $INFOFILE
         GETINOPT $*
}

# Launchpad checks.
#
if [ `uname` != "AIX" ]; then
   echo "Runs on AIX only."
   exit 1
else
   EXPIRY=`date +"%Y"`
   if [ $EXPIRY -gt 2015 ]; then
      LOGERROR "FATAL: The tool run.ksh expired!!!"
      exit 1
   fi
   if [ ! -f /usr/bin/ksh93 ]; then
      echo "Enhanced korn shell is missing."
      exit 1
   fi
   for dir in logs properties lib misc python perl ; do
       if [ ! -d ../$dir ]; then
          echo "Missing directories/files [$dir], Please check the directories."
          exit 1
       fi
   done
   if [ $# -eq 0 ]; then
      USAGE # Usage
   else
      IPT=`echo $1| tr [A-Z] [a-z]`
   fi
   if [ ! -f ../properties/main.properties ]; then
      echo "Error loading main properties file."
      exit 1
   else
      . ../properties/main.properties
      PROPFILE=../properties/main.properties
      VALIDATEFILE $PROPFILE
   fi
fi
# End of checks.

echo $CLEAR
case $IPT in
            -interactive)
                     LOGINFO "->Invoked int mode."
                     echo ">>" # Tested on Linux and AIX. Can have -ne flag.
                     read -t 9 argmt
                     while [ $argmt != "q" ]; do
                           echo ">>"
                           read -t 9 argmt
                     done
                     LOGINFO "Exited int mode."
                     exit 0
                     ;;
            -info|-i)
                     sed -n '3,11'p $0|sed 's/#//' #| sed  -e :a -e 's/^.\{1,167\}$/ & /;ta'
                     exit 0
                     ;;
            -version|-v)
                     sed -n '5'p $0|awk '{print $4}'
                     exit 0
                     ;;
            -help|-h)
                     USAGE
                     ;;
            -file|-f)
                     if [ $# -gt 1 ]; then
                        YOELREY $*
                        IPTFILE=$2
                        PARSEFILE $IPTFILE
                        LOGCLEAN
                        MAIN_INT $*
                        if [ ! -f ../misc/run.lock ]; then
                           LOGWAR "Another instance is running. Script is locked."
                           exit 1
                        fi
                        mv ../misc/run.lock ../misc/run.lockx
                        MAIN $*
                        mv ../misc/run.lockx ../misc/run.lock
                        echo "<" >> $INFOFILE
                     else
                        LOGERROR "-file|-f: missing argument."
                        LOGERROR "Filename is followed by -f|-file argument."
                        USAGE
                     fi
                     ;;
            *)
              LOGERROR "Unrecognized input: $1"
              USAGE
              ;;
esac
#endMain