#!/usr/bin/env bash

#
#
# tls_ssl_ciphers_check.sh
# v1.0.0
# 6/13/2019
# r2d2c3p0.
#
#
#

# variables (switches).
protocol_tls10=0		# TLSv1.0 Protocol
protocol_tls11=0		# TLSv1.1 Protocol
protocol_tls12=0		# TLSv1.2 Protocol
protocol_ssl2=0			# SSLv2 Protocol
protocol_ssl3=0			# SSLv3 Protocol

# error codes.
ERR_BASH=255
ERR_USAGE=254

# color codes.
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# functions.
print_usage() {
	echo "USAGE: Incorrect usage."
	exit ${ERR_USAGE}
}

# main.
if [[ $(kill -l | grep -c SIG) -eq 0 ]]; then
	printf "\n\033[1;35m Please make sure you're calling me without leading \"sh\"! Bye...\033[m\n\n" >&2 && exit ${ERR_BASH}
else
	if [[ -z "${BASH_VERSINFO[0]}" ]]; then
		printf "\n\033[1;35m Please make sure you're using \"bash\"! Bye...\033[m\n\n" >&2 && exit ${ERR_BASH}
	fi
fi

if [[ $# -eq 0 ]]; then
	echo "ERROR| usage error, use -h|--help for help."
	exit ${ERR_USAGE}
else
	input_arguments="$@"
	while [[ $# -ne 0 ]]; do
			input_argument=${1}
			case ${input_argument} in
					-v10|--version10)
									protocol_tls10=1
									shift;
									;;
					-v11|--version11)
									protocol_tls11=1
									shift;
									;;
					-v12|--version12)
									protocol_tls12=1
									shift;
									;;
							-a|--all)
									protocol_tls12=1
									protocol_tls11=1
									protocol_tls10=1
									protocol_ssl3=1
									protocol_ssl2=1
									shift;
									;;
						   -h|--help)
									print_usage;
									shift;
									;;
					  -v2|--version2)
									protocol_ssl2=1
									shift;
									;;
					  -v3|--version3)
									protocol_ssl3=1
									shift;
									;;
								   *)
									echo "ERROR| invalid input argument ${input_arguments}."
									echo "INFO| use -h|--help for help."
									exit ${ERR_USAGE}
									shift;
									;;
			esac
	done
fi

for connection_string in $(cat intranet.txt); do
	connection_name=$(echo ${connection_string} | awk -F "," '{print $1}')
	connection_host=$(echo ${connection_string} | awk -F "," '{print $2}')
	connection_port=$(echo ${connection_string} | awk -F "," '{print $3}')
	echo "-----------------------------------------------------------------"
	nslookup ${connection_host} >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		echo " ${connection_name}=${connection_host}:${connection_port}"
		timeout 1 bash -c "</dev/tcp/${connection_host}/${connection_port}" >/dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			#for ciphers_a in $(openssl ciphers 'ALL:eNULL' | tr ':' ' '); do
			#done
			if [[ ${protocol_tls12} -eq 1 ]]; then
				tls12_check=0
				for Cipher in $(openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'); do
					openssl s_client -connect ${connection_host}:${connection_port} -tls1_2 -cipher "${Cipher}" -msg 2>/dev/null | grep ChangeCipherSpec >/dev/null 2>&1
					if [[ $? -eq 0 ]]; then
						echo "  ${connection_host}[:${connection_port}] using [TLSv1.2] with ${Cipher} --> ${BLINK}${GREEN}Passed${NORMAL}."
						tls12_check=1
					else
						x=0;
						#echo "  ${connection_host}[:${connection_port}] using [TLSv1.2] with ${Cipher} --> ${BLINK}${RED}Failed${NORMAL}."
					fi
				done
				[[ ${tls12_check} -eq 0 ]] && { echo "  ${connection_host}[:${connection_port}] using [TLSv1.2] --> ${BLINK}${YELLOW}Not Allowed${NORMAL}." ; }
			fi
			if [[ ${protocol_tls11} -eq 1 ]]; then
				tls11_check=0
				for Cipher in $(openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'); do
					openssl s_client -connect ${connection_host}:${connection_port} -tls1_1 -cipher "${Cipher}" -msg 2>/dev/null | grep ChangeCipherSpec >/dev/null 2>&1
					if [[ $? -eq 0 ]]; then
						echo "  ${connection_host}[:${connection_port}] using [TLSv1.1] with ${Cipher} --> ${BLINK}${GREEN}Passed${NORMAL}."
						tls11_check=1
					else
						x=0;
						#echo "  ${connection_host}[:${connection_port}] using [TLSv1.1] with ${Cipher} --> ${BLINK}${RED}Failed${NORMAL}."
					fi
				done
				[[ ${tls11_check} -eq 0 ]] && { echo "  ${connection_host}[:${connection_port}] using [TLSv1.1] --> ${BLINK}${YELLOW}Not Allowed${NORMAL}." ; }
			fi
			if [[ ${protocol_tls10} -eq 1 ]]; then
				tls10_check=0
				for Cipher in $(openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'); do
					openssl s_client -connect ${connection_host}:${connection_port} -tls1 -cipher "${Cipher}" -msg 2>/dev/null | grep ChangeCipherSpec >/dev/null 2>&1
					if [[ $? -eq 0 ]]; then
						echo "  ${connection_host}[:${connection_port}] using [TLSv1.0] with ${Cipher} --> ${BLINK}${GREEN}Passed${NORMAL}."
						tls10_check=1
					else
						x=0;
						#echo "  ${connection_host}[:${connection_port}] using [TLSv1.0] with ${Cipher} --> ${BLINK}${RED}Failed${NORMAL}."
					fi
				done
				[[ ${tls10_check} -eq 0 ]] && { echo "  ${connection_host}[:${connection_port}] using [TLSv1.0] --> ${BLINK}${YELLOW}Not Allowed${NORMAL}." ; }
			fi
			if [[ ${protocol_ssl3} -eq 1 ]]; then
				ssl3_check=0
				for Cipher in $(openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'); do
					openssl s_client -connect ${connection_host}:${connection_port} -ssl3 -cipher "${Cipher}" -msg 2>/dev/null | grep ChangeCipherSpec >/dev/null 2>&1
					if [[ $? -eq 0 ]]; then
						echo "  ${connection_host}[:${connection_port}] using [SSLv3] with ${Cipher} --> ${BLINK}${GREEN}Passed${NORMAL}."
						ssl3_check=1
					else
						x=0;
						#echo "  ${connection_host}[:${connection_port}] using [SSLv3] with ${Cipher} --> ${BLINK}${RED}Failed${NORMAL}."
					fi
				done
				[[ ${ssl3_check} -eq 0 ]] && { echo "  ${connection_host}[:${connection_port}] using [SSLv3] --> ${BLINK}${YELLOW}Not Allowed${NORMAL}." ; }
			fi
			if [[ ${protocol_ssl2} -eq 1 ]]; then
				ssl2_check=0
				for Cipher in $(openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'); do
					openssl s_client -connect ${connection_host}:${connection_port} -ssl2 -cipher "${Cipher}" -msg 2>/dev/null | grep ChangeCipherSpec >/dev/null 2>&1
					if [[ $? -eq 0 ]]; then
						echo "  ${connection_host}[:${connection_port}] using [SSLv2] with ${Cipher} --> ${BLINK}${GREEN}Passed${NORMAL}."
						ssl2_check=1
					else
						x=0;
						#echo "  ${connection_host}[:${connection_port}] using [SSLv2] with ${Cipher} --> ${BLINK}${RED}Failed${NORMAL}."
					fi
				done
				[[ ${ssl2_check} -eq 0 ]] && { echo "  ${connection_host}[:${connection_port}] using [SSLv2] --> ${BLINK}${YELLOW}Not Allowed${NORMAL}." ; }
			fi
		else
			echo "  ${connection_host}:${connection_port} ${BLINK}${RED}Refused$${NORMAL}."
		fi
	else
		echo "  ${connection_host} ${BLINK}${RED}NOT found${NORMAL}."
	fi
done
echo "-----------------------------------------------------------------"

#end_tls_ssl_ciphers_check.sh
