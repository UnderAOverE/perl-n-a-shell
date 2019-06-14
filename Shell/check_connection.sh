#!/usr/bin/bash

#
#
# check_connections.sh
# v1.0.0
# 6/13/2019
#
#

# main
for conn_string in $(cat intranet.txt); do
	connection_name=$(echo ${conn_string} | awk -F "," '{print $1}')
	connection_host=$(echo ${conn_string} | awk -F "," '{print $2}')
	connection_port=$(echo ${conn_string} | awk -F "," '{print $3}')
	echo "--------------------------------------------------------------"
	nslookup ${connection_host} >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo " ${connection_name}=${connection_host}:${connection_port}"
		java -jar TLS_SSL.jar ${connection_host} ${connection_port} | egrep -v "SIGNIFICANT|encryption|status|compression|-|certificate|CN\="
	else
		echo " ${connection_name}"
		echo "  - ${connection_host}:${connection_port}"
		echo "  - NOT Found"
	fi
	echo "--------------------------------------------------------------"
done

#end_check_connections.sh
