#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: stopAPP.sh,v 1.28 2013/04/24 17:14:01 jwilliam Exp $
# $Log: stopAPP.sh,v $
# Revision 1.28  2013/04/24 17:14:01  jwilliam
# Changed hostnames from txglsp01 to txglspv6 and txglst01 to txglstv6
#
# Revision 1.27  2010/06/29 19:57:34  bfortman
# added stopAPACHE2.sh to EDI
#
# Revision 1.26  2009/12/02 16:00:27  dcastigl
# added euwcsp01 euwcsp02
#
# Revision 1.25  2009/10/30 18:03:04  dcastigl
# added wcs02p01 wcs02p02
#
# Revision 1.24  2009/10/09 20:06:46  bfortman
# added WCS ESP agent
#
# Revision 1.23  2009/06/05 18:41:05  bfortman
# added stopDMGR.sh dep servers
#
# Revision 1.22  2009/06/05 18:30:03  bfortman
# added stopDMGR.sh
#
# Revision 1.21  2009/05/11 18:18:23  bfortman
# separated MQ stop from WCS and added to stopAPP script
#
# Revision 1.20  2009/03/26 19:23:17  bfortman
# Removed stopEDI.sh from EDI DEV and QA
#
# Revision 1.19  2009/02/25 15:37:00  bfortman
# cleanup
#
# Revision 1.18  2008/02/25 19:02:21  bfortman
# clean up
#
# Revision 1.17  2007/08/17 21:23:49  bfortman
# added support for txglsp01
#
# Revision 1.16  2007/08/07 14:58:05  bfortman
# added support for txedip02
#
# Revision 1.15  2007/07/23 17:58:45  bfortman
# changes for new QA systems
#
# Revision 1.14  2007/06/22 15:44:49  bfortman
# added ESP start-stop
#
# Revision 1.13  2007/03/06 20:14:31  bfortman
# added support for txedip01
#
# Revision 1.12  2007/02/13 22:00:55  bfortman
# added support for txedit01
#
# Revision 1.11  2006/12/15 16:23:56  dcastigl
# added txessp01 TPC stop
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
# Revision 1.6  2005/09/23 20:35:51  megglest
# removed MQ from EDI
#
# Revision 1.5  2005/09/16 14:23:32  megglest
# tweaking the script configuration and messages
#
# Revision 1.4  2005/09/15 21:47:14  megglest
# consolidating all stopAPP.sh across all servers
#
# Revision 1.3  2005/09/15 18:48:29  megglest
# all hosts resolved into a single file
#
# Revision 1.1  2004/03/21 17:08:02  megglest
# minor changes
#

# stop applications on this box

id=`whoami`
if [ "$id" != 'root' ] ; then
	echo "$0: must be root: aborting"
	exit 1
fi


# for this box, what applications are running?
HOST=`hostname`
case "$HOST" in
	# Express Production Node Deployment Servers
	txndsp11|txndsq12)
		/tti/bin/stopDMGR.sh
		;;

	# Express Production WAS and CTG Servers
	txwasp11|txwasp12|txwasq11|txwasq12)
		/tti/bin/stopWAS.sh
		/tti/bin/stopCTG.sh
		;;

	# Express Dev & QA WAS, CTG, and MQ Servers
	txwast11)
		/tti/bin/stopWAS.sh
		/tti/bin/stopWAS_J.sh
		/tti/bin/stopWAS_K.sh
		/tti/bin/stopCTG.sh
		/tti/bin/stopDMGR.sh
		/tti/bin/stopDMGR_J.sh
		/tti/bin/stopDMGR_K.sh
		/tti/bin/stopMQS.sh
		/tti/bin/stopMQS_J.sh
		/tti/bin/stopMQS_K.sh
		;;

	# Express Production MQ Servers
	txmqsp11|txmqsp12|txmqsq11|txmqsq12)
		/tti/bin/stopMQS.sh
		;;

	# OnDemand server
	tximg001)
		/tti/bin/stopARS.sh
		;;

        # EDI DEV
        txedit11)
                /tti/bin/stopAPACHE2.sh
                /tti/bin/stopMYSQL.sh
                /tti/bin/stopEDI.sh
                ;;

        # EDI PROD
        txedip11)
                /tti/bin/stopAPACHE2.sh
                /tti/bin/stopESP.sh
                /tti/bin/stopMYSQL.sh
                /tti/bin/stopEDI.sh
                ;;

	# EDI DMZ Perimeter server
	txedip12)
		/tti/bin/stopPS.sh
		;;

	# TSM server
	txtsmp01)
		#/tti/bin/stopTSM.sh
		;;

	# WCS servers
	txwcsp11|wcs02p11|wcs02p12|euwcsp11|euwcsp12)
		/tti/bin/stopESP.sh
		/tti/bin/stopCONNX.sh
		/tti/bin/stopWCS.sh
		/tti/bin/stopMQS.sh
		;;

	# WCS development and qa environments
	txwcst11|txwcst22|txwcste2)
		/tti/bin/stopWCS.sh			# stop WCS before MQ
		/tti/bin/stopMQS.sh			# stop MQ after WCS
		;;

	# E5 Financials
	txglspv6|txglstv6)
		/tti/bin/stopQSP.sh
		;;

	*)
		echo "$0: unknown host: aborting"
		exit 1
		;;
esac
