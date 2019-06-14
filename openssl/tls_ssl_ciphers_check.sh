#!/usr/bin/bash

#
#
# check_connections.sh
# v1.0.0
# 6/13/2019
#
#

# variables
protocol_ssl2=""
protocol_ssl3=""
protocol_tls10=""
protocol_tls11=""
protocol_tls12=""

# function
function openssl_c {
	protocol_string=$(echo ${3} ${4} ${5} ${6} ${7})
	server_name=${1}
	server_port=${2}
	for protocol_version in $(echo ${protocol_string}); do
		case ${protocol_version} in
				tls1) pprotocol="TLSv1.0" ;;
				tls1_1) pprotocol="TLSv1.1" ;;
				tls1_2) pprotocol="TLSv1.2" ;;
				ssl2) pprotocol="SSLv2" ;;
				ssl3) pprotocol="SSLv3" ;;
				*) pprotocol="NULL" ;;
		esac
		for ciphers_a in $(openssl ciphers 'ALL:eNULL' | tr ':' ' '); do
			#openssl s_client \
			#-connect ${server_name}:${server_port} \
			#-cipher ${ciphers_a} -${protocol_version} < /dev/null > /dev/null 2>&1 \
			#&& echo -e "   ${pprotocol}: ${ciphers_a}"
			openssl s_client -connect ${server_name}:${server_port} 2>/dev/null </dev/null \
			| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' 1>/var/tmp/cert.txt 2>/dev/null;
			if [[ -s /var/tmp/cert.txt ]]; then
			  #openssl x509 -in /var/tmp/cert.txt -noout -text \
			  #| egrep "Signature Algorithm|Issuer|Not Before|Not After|Subject\:" \
			  #| grep -v "CA Issuers" \
			  #| head -5; \
			  #openssl x509 -in /var/tmp/cert.txt -noout -serial  
			  echo "   ${pprotocol}: ${ciphers_a}"
			fi
		done
	done
}

# main
if [[ $# -eq 0 ]]; then
	echo "ERROR| usage error, use -h|--help for help."
	exit 1
else
	input_arguments="$@"
	while [[ $# -ne 0 ]]; do
			input_argument=${1}
			case ${input_argument} in
					  -v2|--version2)
									protocol_ssl2="ssl2"
									shift;
									;;
					  -v3|--version3)
									protocol_ssl3="ssl3"
									shift;
									;;
					-v10|--version10)
									protocol_tls10="tls1"
									shift;
									;;
					-v11|--version11)
									protocol_tls11="tls1_1"
									shift;
									;;
					-v12|--version12)
									protocol_tls12="tls1_2"
									shift;
									;;
							-a|--all)
									protocol_tls12="tls1_2"
									protocol_tls11="tls1_1"
									protocol_tls10="tls1"
									protocol_ssl3="ssl3"
									protocol_ssl2="ssl2"
									shift;
									;;
						   -h|--help)
									print_usage;
									shift;
									;;
								   *)
									echo "ERROR| invalid input argument ${input_arguments}."
									echo "INFO| use -h|--help for help."
									exit 1
									shift;
									;;
			esac
	done
	for conn_string in $(cat intranet.txt); do
		connection_name=$(echo ${conn_string} | awk -F "," '{print $1}')
		connection_host=$(echo ${conn_string} | awk -F "," '{print $2}')
		connection_port=$(echo ${conn_string} | awk -F "," '{print $3}')
		echo "--------------------------------------------------------------"
		nslookup ${connection_host} >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			echo " ${connection_name}=${connection_host}:${connection_port}"
			timeout 1 bash -c "</dev/tcp/${connection_host}/${connection_port}" >/dev/null 2>&1
			if [[ $? -eq 0 ]]; then	
				openssl_c ${connection_host} ${connection_port} ${protocol_tls12} ${protocol_tls11} ${protocol_tls10} ${protocol_ssl3} ${protocol_ssl2}
			else
				echo "  - ${connection_host}:${connection_port} Refused."
			fi
		else
			echo "  - ${connection_host} NOT found."
		fi
	done
	echo "--------------------------------------------------------------"
fi

#end_check_connections.sh
