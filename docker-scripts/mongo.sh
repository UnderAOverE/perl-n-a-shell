#!/bin/bash

#
#
# 12/10/2017.
# r2d2c3p0.
# mongo.sh
# mongo docker run command.
# v1.0.0
#

# command arguments. want more? use: docker run --help
# --name = name of the container.
# --volume = maps local filesystem.
# --publish = maps the container port to the host.
# --detach = run in background.

docker run \
	--name r2d2c3p0-mongo \
	--publish 27017:27017 \
	--volume /home/r2d2c3p0/dockerdata/db:/data/db \
	--detach mongo

#end_mongo.sh
