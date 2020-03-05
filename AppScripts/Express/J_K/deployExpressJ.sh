#!/bin/sh

# Revision 2020/03/02 13:05:57  sreddy
# *** J & K environments ***
#
# Express WAS J deployment script.

id=`whoami`
case "$id" in
        root*)  sh='su - xadm' ;;
        xadm*)  sh=sh ;;
        operator*)      sh=sh ;;
        *)      echo "$0: must be either xadm or root: aborting"
                exit 1
                ;;
esac

DEP=/usr/WebSphereJ/Express/profiles/JDmgr/bin/

HOST=`hostname`
case "$HOST" in
        txwast11)
                $sh -c "$DEP/wsadmin.sh -lang jython -f /tti/py/ExpressTTIDeploy.py J"
                ;;
        *)
                echo "$0: unknown host: aborting"
                exit 1
                ;;
esac

#end_deployExpressJ.sh