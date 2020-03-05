#!/bin/sh

# 2020/03/02 13:05:57  sreddy
# *** J & K environments ***


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
	txwast11)
		/tti/bin/startCTG.sh
		/tti/bin/startMQS_J.sh
		/tti/bin/startDMGR_J.sh
		/tti/bin/startWAS_J.sh
		;;
	*)
		echo "$0: unknown host: aborting"
		exit 1
		;;
esac
