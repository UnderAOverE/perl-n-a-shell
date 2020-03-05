#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: stopWAS.sh,v 1.6 2009/06/05 17:49:10 bfortman Exp $
# $Log: stopWAS.sh,v $
# Revision 1.6  2009/06/05 17:49:10  bfortman
# removed deployment manager shutdown
#
# Revision 1.5  2007/07/23 17:58:31  bfortman
# changes for new QA systems
#
# Revision 1.4  2006/01/04 20:28:56  megglest
# changed /tticommands -> /tti/bin
# for WebSphere scripts changed
# 	/usr/WebSphere/AppServer/bin -> $APP
# 	/usr/WebSphere/DeploymentManager/bin -> $DEP
#
# Revision 1.3  2005/09/16 14:23:33  megglest
# tweaking the script configuration and messages
#
# Revision 1.2  2005/09/15 14:27:37  megglest
# consolidated script from all servers
#
# Revision 1.5  2004/02/24 04:45:54  megglest
# testing changes
#
# Revision 1.4  2004/02/01 20:45:55  megglest
# fixed the kill statement
#
# Revision 1.3  2004/02/01 20:36:41  megglest
# added quotes
#
# Revision 1.2  2004/01/25 18:02:53  megglest
# changes
#
# Revision 1.1  2004/01/25 17:39:05  megglest
# initial vesrion
#

# stop the WAS application components on this box

id=`whoami`
case "$id" in
	root*)	sh='su - xadm' ;;
	xadm*)	sh=sh ;;
	operator*)	sh=sh ;;
	*)	echo "$0: must be either xadm or root: aborting"
		exit 1
		;;
esac

if [ "$1" = 'kill' ] ; then
	ps -ef | grep 'java.*WS' | grep 'WebSphereK' | grep -v grep | awk '{print $2}' | while read pid
	do
		kill -9 $pid
	done
	sleep 30
	exit 0
fi

APP1=/usr/WebSphereK/Express/profiles/KNode01/bin
APP2=/usr/WebSphereK/Express/profiles/KNode02/bin
DEP=/usr/WebSphereK/Express/profiles/KDmgr/bin

case `hostname` in
	txwast11)		
		echo "stop tti_WLM_kserver1"
		$sh -c "$APP1/stopServer.sh tti_WLM_kserver1"
		echo "stop tti_WLM_kserver2"
		$sh -c "$APP2/stopServer.sh tti_WLM_kserver2"
		echo "stop K Node1"
		$sh -c "$APP1/stopNode.sh"
		echo "stop K Node2"
		$sh -c "$APP2/stopNode.sh"
		#echo "stop K DMGR"
		#$sh -c "$DEP/stopManager.sh"
		;;
	*)
		echo "$0: this is K environment script, skipping..."
		;;
esac
