#!/usr/bin/ksh

port_number=${2}
host_name=${1}

for protocol in -ssl2 -ssl3 -tls1 -tls1_1 -tls1_2; do
	case ${protocol} in 
		-ssl2) Protocol="SSLv2";;
		-ssl3) Protocol="SSLv3";;
		-tls1) Protocol="TLSv1.0";;
	  -tls1_1) Protocol="TLSv1.1";;
	  -tls1_2) Protocol="TLSv1.2";;
		*) x=1;;
	esac
	for Cipher in `openssl ciphers | awk -F ":" '{ for (cph=1;cph<NF+1;cph++) if (length($cph) != 0) print $cph }'`; do
		echo | openssl s_client -connect ${host_name}:${port_number} ${protocol} -cipher "${Cipher}" >/dev/null 2>&1 
		if [[ $? -eq 0 ]]; then
			echo "${host_name}[:${port_number}] using [${Protocol}] with ${Cipher} - Passed."
		else
			x=0;
			#echo "${host_name}[:${port_number}] using [${Protocol}] with ${Cipher} - Failed."
		fi
	done
done
