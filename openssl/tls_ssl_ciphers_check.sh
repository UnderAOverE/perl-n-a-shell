#!/usr/bin/bash

#
#
# check_connections.sh
# v1.0.0
# 6/13/2019
#
#

# function
function openssl_c {
	server_name=${1}
	server_port=${2}
	for protocol_version in ssl2 ssl3 tls1 tls1_1 tls1_1; do
		case ${protocol_version} in
				ssl2) pprotocol="SSLv2" ;;
				ssl3) pprotocol="SSLv3" ;;
				tls1) pprotocol="TLSv1.0" ;;
				tls1_1) pprotocol="TLSv1.1" ;;
				tls1_1) pprotocol="TLSv1.2" ;;
				*) pprotocol="NULL" ;;
		esac
		for ciphers_a in $(openssl ciphers 'ALL:eNULL' | tr ':' ' '); do
			openssl s_client \
			-connect ${server_name}:${server_port} \
			-cipher ${ciphers_a} -${protocol_version} < /dev/null > /dev/null 2>&1 \
			&& echo -e "   ${pprotocol}:\t${ciphers_a}"
		done
	done
}

# main
for conn_string in $(cat intranet.txt); do
	connection_name=$(echo ${conn_string} | awk -F "," '{print $1}')
	connection_host=$(echo ${conn_string} | awk -F "," '{print $2}')
	connection_port=$(echo ${conn_string} | awk -F "," '{print $3}')
	echo "--------------------------------------------------------------"
	nslookup ${connection_host} >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo " ${connection_name}=${connection_host}:${connection_port}"
		openssl_c ${connection_host} ${connection_port}
	else
		echo " ${connection_name}"
		echo "  - ${connection_host} NOT found."
	fi
done
echo "--------------------------------------------------------------"

#end_check_connections.sh
