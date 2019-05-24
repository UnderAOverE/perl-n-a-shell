openssl s_client -connect www.google.com:443 2>/dev/null </dev/null \
  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' 1>/var/tmp/cert.txt; \
  openssl x509 -in /var/tmp/cert.txt -noout -text \
  | egrep "Signature Algorithm|Issuer|Not Before|Not After|Subject\:" \
  | grep -v "CA Issuers" \
  | head -5; \
  openssl x509 -in /var/tmp/cert.txt -noout -serial
