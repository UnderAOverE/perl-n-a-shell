#!/bin/sh

# Revision 1.30  2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# $Id: stopMQS.sh,v 1.11 2009/05/11 20:58:41 bfortman Exp $
# $Log: stopMQS.sh,v $
# Revision 1.11  2009/05/11 20:58:41  bfortman
# added step to clean up hung mq processes
#
# Revision 1.10  2006/05/15 18:49:08  megglest
# minor changes due to EU WCS
#
# Revision 1.9  2006/01/29 15:53:59  megglest
# removed the xadm id
#
# Revision 1.8  2005/09/24 17:55:37  megglest
# fixed messed up case
#
# Revision 1.7  2005/09/23 20:35:51  megglest
# removed MQ from EDI
#
# Revision 1.6  2005/09/16 14:23:33  megglest
# tweaking the script configuration and messages
#
# Revision 1.5  2005/09/15 21:45:08  megglest
# consolidating all stopMQS.sh across all servers
#

# stop the MQ Series queues on this box

# based on hostname and id, get the right account to shutdown MQ
HOST=`hostname`
id=`whoami`

# decide which id to use
case "$id" in
	root*)  sh='su - mqm' ;;
	mqm*)  sh=sh ;;
	*)  echo "$0: must be either mqm or root: aborting"
		exit 1
		;;
esac

# collect the queue managers on this server
qmgrs=''
/usr/mqm/bin/dspmq | grep "TTI.K" | grep -i running | sed 's/[()]/ /g' | while read line
do
	set -- $line
	qmgrs="$qmgrs $2"
done

# shutdown each queue manager
for qmgr in $qmgrs
do
	$sh -c "endmqcsv $qmgr"				# command server
	$sh -c "endmqm -i $qmgr"			# stop immediate queue manager
done

echo "stop issued for K QMgrs"
echo "waiting for 'ended'"

# wait for the queues to shutdown
running=1
while [ $running -eq 1 ]
do
	/usr/mqm/bin/dspmq | grep "TTI.K" | grep -ic ended | read qcnt
	/usr/mqm/bin/dspmq | grep "TTI.K" | wc -l | read lines
	if [ $qcnt -eq $lines ] ; then
		echo "all K QMgrs are down"
		running=0
	else
		echo "$qcnt of $lines of K QMgrs are down"
	fi
	sleep 3
done

# stop the listener for each queue manager
for qmgr in $qmgrs
do
	$sh -c endmqlsr -m $qmgr
done

# Make sure there are no hung listener processes, if so clean up
sleep 5
ps -ef | grep "TTI.K" | grep -v grep | grep runmqlsr | awk '{print $2}' | xargs -i kill -9 {} > /dev/null 2>&1