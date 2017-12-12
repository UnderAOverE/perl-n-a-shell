#!/bin/bash

#
# cleanenvironment.sh
# r2d2c3p0.
# 12/11/2017
# v1.0.0
# script to clean the environment by stopping and removing the contianers.
# local volumes(including dangling) will be removed.
#

# functions.
function Echo { 
	echo "`date +\"[%m/%d/%Y %H:%M:%S %Z]\"` $@" 
}

#
# DANGER: Use this script with caution, recommended for development ONLY. #
#

# main.
function Main {
	Echo "stopping all the running containers."
	docker stop $(docker ps -aq) 2>/dev/null
	Echo "removing containers with status=created and status=exited."
	docker rm $(docker ps -a -f status=exited -f status=created -q) 2>/dev/null
	Echo "force remove all the containers."
	docker rm -f $(docker ps -aq) 2>/dev/null
	Echo "reclaim space, remove local volumes."
	docker volume rm $(docker volume ls -f dangling=true -q) 2>/dev/null
	docker volume prune -f 2>/dev/null
}

Main; exit 0

#end_cleanenvironment.sh
