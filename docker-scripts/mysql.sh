#!/bin/bash

#
#
# 12/10/2017.
# r2d2c3p0.
# mysql.sh
# MySQL docker run command.
# v1.0.0
#

# command arguments. want more? use: docker run --help
# --name = name of the container.
# --volume = maps local filesystem.
# --publish = maps the container port to the host.
# --detach = run in background.
# --env = environment property, MYSQL_ALLOW_EMPTY_PASSWORD=yes, sets no password.

docker run \
	--name r2d2c3p0-mysql \
	--env MYSQL_ALLOW_EMPTY_PASSWORD=yes \
	--volume /home/r2d2c3p0/dockerdata/mySQL:/var/lib/mysql \
	--publish 3306:3306 \
	--detach mysql

#end_mysql.sh
