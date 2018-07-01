for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 41 42 43 44 45 46 47 48; do
	for port in 7402 7404 7406; do
		echo "server${i}p port ${port}:"
		#result=`java -jar TLS_SSL.jar server${i}p ${port} | grep "CN\="`
		result=`openssl s_client -connect server${i}p:${port} </dev/null 2>/dev/null | openssl x509 -text | grep -E "Subject:|Signature Algorithm" | head -2`
		echo "     ${result}"
	done
done
