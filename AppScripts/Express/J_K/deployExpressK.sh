#!/bin/sh

# Revision 2020/03/02 13:05:57  sreddy
# *** J & K environments ***
#
# Express WAS K deployment script.

id=`whoami`
case "$id" in
        root*)  sh='su - xadm' ;;
        xadm*)  sh=sh ;;
        operator*)      sh=sh ;;
        *)      echo "$0: must be either xadm or root: aborting"
                exit 1
                ;;
esac

DEP=/usr/WebSphereK/Express/profiles/KDmgr/bin/

HOST=`hostname`
case "$HOST" in
        txwast11)
                $sh -c "$DEP/wsadmin.sh -lang jython -f /tti/py/ExpressTTIDeploy.py K"
                ;;
        *)
                echo "$0: unknown host: aborting"
                exit 1
                ;;
esac

#end_deployExpressK.sh