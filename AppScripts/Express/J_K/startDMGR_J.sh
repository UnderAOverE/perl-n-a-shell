#!/bin/sh

# Revision 2020/03/02 13:05:57  sreddy
# *** added J & K environments ***
#
# start the WAS Deployment Manager Only

id=`whoami`
case "$id" in
	root*)	sh='su - xadm' ;;
	xadm*)	sh=sh ;;
	operator*)	sh=sh ;;
	*)	echo "$0: must be either xadm or root: aborting"
		exit 1
		;;
esac

DEP=/usr/WebSphereJ/Express/profiles/JDmgr/bin

HOST=`hostname`
case "$HOST" in
	txwast11)
		echo "start J Deployment Manager"
		$sh -c $DEP/startManager.sh
		;;
	*)
		echo "$0: this is J environment script, skipping..."		
		;;
esac
