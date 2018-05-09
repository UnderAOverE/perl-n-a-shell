#!/bin/bash

#
# 12/10/2017.
# r2d2c3p0.
# maven.sh
# maven docker run command.
# v1.0.0
#

# command arguments. want more? use: docker run --help
# --interactive = keeps STDIN open.
# --tty = psuedo TTY.
# --volume = maps local filesystem.
# --workdir = local working directory.
# --rm = remove container after execution.

#docker run --rm --interactive --tty maven mvn --version

docker run \
	--rm \
	--interactive \
	--tty \
	--volume $(pwd):/maven \
	--workdir /maven maven mvn archetype:generate \
    	-DgroupId=com.docker.example \
    	-DartifactId=DockerExample \
    	-DarchetypeArtifactId=maven-archetype-webapp \
    	-DinteractiveMode=false

#end_maven.sh
