#!/bin/bash

#
#
# 12/10/2017.
# r2d2c3p0.
# tomcat.sh
# tomcat docker run command.
# v1.0.0
#

# command arguments. want more? use: docker run --help
# --name = name of the container.
# --publish = maps the container port to the host.
# --detach = run in background.

docker run \
	--name shane-tomcat \
	--publish 8080:8080 \
	--detach tomcat

#end_tomcat.sh
