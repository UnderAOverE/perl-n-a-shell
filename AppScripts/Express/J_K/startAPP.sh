#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: startAPP.sh,v 1.29 2013/04/24 17:14:01 jwilliam Exp $
# $Log: startAPP.sh,v $
# Revision 1.29  2013/04/24 17:14:01  jwilliam
# Changed hostnames from txglsp01 to txglspv6 and txglst01 to txglstv6
#
# Revision 1.28  2011/02/21 21:44:57  sgrieve
# *** empty log message ***
#
# Revision 1.27  2010/06/29 19:57:23  bfortman
# added startAPACHE2.sh to EDI
#
# Revision 1.26  2009/12/02 16:00:16  dcastigl
# added euwcsp01 euwcsp02
#
# Revision 1.25  2009/10/30 21:24:00  dcastigl
# added wcs02p01 and wcs02p02
#
# Revision 1.24  2009/10/09 20:06:41  bfortman
# added WCS ESP agent
#
# Revision 1.23  2009/06/05 18:41:21  bfortman
# added startDMGR.sh to dep servers
#
# Revision 1.22  2009/06/05 18:29:46  bfortman
# added startDMGR.sh
#
# Revision 1.21  2009/05/11 18:18:42  bfortman
# separated MQ start from WCS and added to startAPP script
#
# Revision 1.20  2009/03/26 19:22:33  bfortman
# Removed startESP.sh from EDI DEV and QA
#
# Revision 1.19  2009/02/25 15:36:53  bfortman
# cleanup
#
# Revision 1.18  2008/02/25 19:03:15  bfortman
# clean up
#
# Revision 1.17  2007/08/17 21:23:35  bfortman
# added support for txglsp01
#
# Revision 1.16  2007/08/07 14:58:15  bfortman
# added support for txedip02
#
# Revision 1.15  2007/07/23 17:58:39  bfortman
# changes for new QA systems
#
# Revision 1.14  2007/06/22 15:44:55  bfortman
# added ESP start-stop
#
# Revision 1.13  2007/03/06 20:14:55  bfortman
# added support for txedip01
#
# Revision 1.12  2007/02/13 22:01:04  bfortman
# added support for txedit01
#
# Revision 1.11  2006/12/15 16:24:23  dcastigl
# added txessp01 TPC start
#
# Revision 1.10  2006/05/08 16:23:24  kstewart
# updated txwcse1 to txwcste1
#
# Revision 1.9  2006/04/03 16:09:53  megglest
# adjustments for new wcs development servers
#
# Revision 1.8  2006/01/04 20:28:56  megglest
# changed /tticommands -> /tti/bin
# for WebSphere scripts changed
# 	/usr/WebSphere/AppServer/bin -> $APP
# 	/usr/WebSphere/DeploymentManager/bin -> $DEP
#
# Revision 1.7  2005/12/18 18:21:18  megglest
# added checks for txedip03 to start/stop tomcat
#
# Revision 1.6  2005/09/23 20:35:50  megglest
# removed MQ from EDI
#
# Revision 1.5  2005/09/16 14:23:32  megglest
# tweaking the script configuration and messages
#
# Revision 1.4  2005/09/15 22:23:36  megglest
# consolidating all server scripts
#
# Revision 1.1  2004/03/21 17:08:01  megglest
# minor changes
#

# for the current host
# start the application(s) that should run on this host

id=`whoami`
case "$id" in
	root)	sh='su - xadm' ;;
	*)	echo "$0: must be root: aborting"
		exit 1
		;;
esac

HOST=`hostname`
case "$HOST" in
	# Express Production Node Deployment Servers
	txndsp11|txndsq12)
		/tti/bin/startDMGR.sh
		;;

	# Express Production WAS and CTG Servers
	txwasp11|txwasp12|txwasq11|txwasq12)
		/tti/bin/startCTG.sh
		/tti/bin/startWAS.sh
		;;

	# Express Dev & QA WAS, CTG, and MQ Servers
	txwast11)
		/tti/bin/startCTG.sh
		/tti/bin/startMQS.sh
		/tti/bin/startMQS_J.sh
		/tti/bin/startMQS_K.sh
		/tti/bin/startDMGR.sh
		/tti/bin/startDMGR_J.sh
		/tti/bin/startDMGR_K.sh
		/tti/bin/startWAS.sh
		/tti/bin/startWAS_J.sh
		/tti/bin/startWAS_K.sh
		;;

	# Express Production MQ Servers
	txmqsp11|txmqsp12|txmqsq11|txmqsq12)
		/tti/bin/startMQS.sh
		;;

	# WCS servers
	txwcsp11)
		/tti/bin/startWCS.sh
		;;

	# WCS02 servers
	wcs02p11|wcs02p12)
		/tti/bin/startWCS.sh
		;;

	# EUWCS servers
	euwcsp11|euwcsp12)
		/tti/bin/startWCS.sh
		;;

	# WCS development and qa environments
	txwcst11|txwcst21|txwcste2)
		/tti/bin/startMQS.sh		# start MQ before WCS
		/tti/bin/startWCS.sh		# start WCS after MQ
		;;

        # EDI DEV and QA server
	txedit11|txediq11)
		/tti/bin/startEDI.sh
		/tti/bin/startMYSQL.sh
		/tti/bin/startAPACHE2.sh
		;;

        # EDI PROD server
	txedip11)
		/tti/bin/startVLTrader.sh
		/tti/bin/startEDI.sh
		/tti/bin/startMYSQL.sh
		/tti/bin/startESP.sh
		/tti/bin/startAPACHE2.sh
		;;

	# EDI DMZ Perimeter server
	txedip02)
		/tti/bin/startVLProxy.sh
		/tti/bin/startPS.sh
		;;

	# TSM/backup/NetView server
	txtsm001)
		/tti/bin/startTSM.sh
		;;

	# E5 Financials
	txglsp01|txglst01)
		/tti/bin/startQSP.sh
		;;

	# OnDemand server
	tximg001)
		/tti/bin/startARS.sh
		;;

esac
