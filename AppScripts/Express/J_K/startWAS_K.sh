#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: startWAS.sh,v 1.12 2010/04/22 22:43:57 bfortman Exp $
# $Log: startWAS.sh,v $
# Revision 1.12  2010/04/22 22:43:57  bfortman
# new ip addresses
#
# Revision 1.11  2009/06/05 17:49:25  bfortman
# removed deployment manager startup
#
# Revision 1.10  2008/09/26 13:18:01  bfortman
# changed IP of txwast01
#
# Revision 1.9  2008/07/22 13:31:18  bfortman
# 10.1.8 mq IPs changed to 10.1.7
#
# Revision 1.8  2007/07/23 22:10:23  bfortman
# another boo boo fix
#
# Revision 1.7  2007/07/23 21:30:35  bfortman
# boo boo
#
# Revision 1.6  2007/07/23 17:58:24  bfortman
# changes for new QA systems
#
# Revision 1.5  2006/01/29 15:52:50  megglest
# fixed the DEP variable
#
# Revision 1.4  2006/01/04 20:28:56  megglest
# changed /tticommands -> /tti/bin
# for WebSphere scripts changed
# 	/usr/WebSphere/AppServer/bin -> $APP
# 	/usr/WebSphere/DeploymentManager/bin -> $DEP
#
# Revision 1.3  2005/09/16 14:23:32  megglest
# tweaking the script configuration and messages
#
# Revision 1.2  2005/09/15 21:46:44  megglest
# consolidating all stopWAS.sh across all servers
#

# start the WAS components on this server

id=`whoami`
case "$id" in
	root*)	sh='su - xadm' ;;
	xadm*)	sh=sh ;;
	operator*)	sh=sh ;;
	*)	echo "$0: must be either xadm or root: aborting"
		exit 1
		;;
esac

APP1=/usr/WebSphereK/Express/profiles/KNode01/bin
APP2=/usr/WebSphereK/Express/profiles/KNode02/bin
DEP=/usr/WebSphereK/Express/profiles/KDmgr/bin

HOST=`hostname`
case "$HOST" in
	txwast11)
	    #echo "start DMGR"
		#$sh -c "$DEP/startManager.sh"
		echo "start Node1"
		$sh -c "$APP1/startNode.sh"
		echo "start Node2"
		$sh -c "$APP2/startNode.sh"
		echo "start tti_WLM_kserver1"
		$sh -c "$APP1/startServer.sh tti_WLM_kserver1"
		echo "start tti_WLM_kserver2"
		$sh -c "$APP2/startServer.sh tti_WLM_kserver2"
		;;
	*)
		echo "$0: this is K environment script, skipping..."
		;;
esac
