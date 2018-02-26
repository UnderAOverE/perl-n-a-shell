# Script to check if CA is Symantec, DigiCert replaced Symantec.
# 2/26/2018, may not be useful in 2019!!!

# https://cs.chromium.org/chromium/src/net/data/ssl/symantec/README.md
# https://cs.chromium.org/chromium/src/net/cert/symantec_certs.cc

for i in certs.pem; do
	openssl x509 -noout -pubkey -in "${i}" | openssl asn1parse -inform pem -out public.key -noout
	digest=`cat public.key | openssl dgst -sha256 -c | awk -F " " '{print $2}' | sed s/:/,0x/g`
	echo "0x${digest} ${i##*/}";
done

#end.
