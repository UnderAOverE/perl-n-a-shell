#!/bin/sh

# 2020/03/02 13:05:57  sreddy
# *** J & K environments ***
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
	txwast11)
		/tti/bin/stopWAS_J.sh
		/tti/bin/stopCTG.sh
		/tti/bin/stopDMGR_J.sh
		/tti/bin/stopMQS_J.sh
		;;

	*)
		echo "$0: unknown host: aborting"
		exit 1
		;;
esac
