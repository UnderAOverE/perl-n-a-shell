#!/bin/bash

#
#
# 12/10/2017.
# r2d2c3p0.
# mongo.sh
# mongo docker run command.
# v1.1.0 (4/21/2018)
#

# command arguments. want more? use: docker run --help
# --name = name of the container.
# --volume = maps local filesystem.
# --publish = maps the container port to the host.
# --detach = run in background.
# docker exec -it $(container_name) /bin/bash

docker run \
	--name shane-mongo \
	--publish 27017:27017 \
	--volume /home/shane/dockerdata/db:/data/db \
	--detach mongo

#end_mongo.sh
