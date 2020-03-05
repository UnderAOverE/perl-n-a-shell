#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: startMQS.sh,v 1.20 2010/04/28 14:20:53 cholden Exp $
# $Log: startMQS.sh,v $
# Revision 1.20  2010/04/28 14:20:53  cholden
# startMQS.sh
#
# Revision 1.19  2007/07/23 17:59:00  bfortman
# changes for new QA systems
#
# Revision 1.18  2006/05/27 06:33:06  megglest
# removing O2WCSQ01 from wcs02 HA cluster
#
# Revision 1.17  2006/05/15 18:49:07  megglest
# minor changes due to EU WCS
#
# Revision 1.16  2006/03/27 19:03:03  megglest
# removed entry for txwct001
#
# Revision 1.15  2006/03/27 19:01:47  megglest
# added diagnostics
#
# Revision 1.14  2006/03/27 18:58:33  megglest
# changed names txwcst02 -> txwcst21, txwcst03 -> txwcste1
#
# Revision 1.13  2006/03/23 21:48:18  megglest
# changed port from 1416 -> 1415
#
# Revision 1.12  2006/03/23 20:09:43  megglest
# changed port from 1415 -> 1416
#
# Revision 1.11  2006/03/18 00:25:30  megglest
# removing queues TXWCST01 and TXWCSQ01 from server txwct001
#
# Revision 1.10  2006/03/13 02:17:32  megglest
# added wildcards after the hostname
#
# Revision 1.9  2006/03/03 16:14:41  megglest
# adding txwcst01, txwcst02, and txwcst03
#
# Revision 1.8  2006/01/29 15:52:38  megglest
# fixed a case and removed the xadm id starting
#
# Revision 1.7  2005/09/23 20:35:51  megglest
# removed MQ from EDI
#
# Revision 1.6  2005/09/16 14:23:32  megglest
# tweaking the script configuration and messages
#
# Revision 1.5  2005/09/16 13:31:01  megglest
# resolved conflict
#

# for the given host
# start the queues for this server

str(){
	QM=$1
	port=$2
	export QM
	$sh -c "strmqm $QM"
	sleep 5
	$sh -c "strmqcsv $QM"
	sleep 5
	$sh -c "nohup runmqlsr -t tcp -p $port -m $QM 2>&1 > /dev/null &"
}

HOST=`hostname`
id=`whoami`

# use the right account to start MQ
case "$id" in
	root*)  sh='su - mqm' ;;
	mqm*)  sh=sh ;;
	*)  echo "$0: must be either mqm or root: aborting"
		exit 1
		;;
esac

case "$HOST" in
	txwast11*)
		str QM.BE.TTI.K.02 1921
        str QM.BE.TTI.K.01 1920
        str QM.APP.TTI.K.02 1821
        str QM.APP.TTI.K.01 1820
        #str QM.BE.TTI.J.01 1720
        #str QM.APP.TTI.J.02 1621
        #str QM.APP.TTI.J.01 1620
        #str QM.BE.TTI.J.02 1721
		;;
	*)
		echo "$0: this is K environment script, skipping..."		
		;;
esac

echo "start issued K(MQ)"
echo "waiting for 'running'"
while true
do
	/usr/mqm/bin/dspmq | grep "TTI.K" | grep -ic running | read qcnt
	/usr/mqm/bin/dspmq | grep "TTI.K" | wc -l | read lines
	if [ $qcnt -eq $lines ] ; then
		echo "all K QMgrs are up"
		exit 0
	else
		echo "$qcnt of $lines of K QMgrs are up"
	fi
	sleep 3
done
