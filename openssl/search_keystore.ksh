#!/usr/bin/ksh

echo "Enter search directory path:"
read root_directory

echo;echo "pkcs12 files are found under below locations:"
for p12_path in `find ${root_directory} -type f -name "*.p12" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${p12_path}"
done

echo;echo "jks files are found under below locations:"
for jks_path in `find ${root_directory} -type f -name "*.jks" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${jks_path}"
done

echo;echo "kdb files are found under below locations:"
for kdb_path in `find ${root_directory} -type f -name "*.kdb" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${kdb_path}"
done

echo;echo "certificates are found under below locations:"
for x5091_path in `find ${root_directory} -type f -name "*.cer" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${x5091_path}"
done
for x5092_path in `find ${root_directory} -type f -name "*.crt" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${x5092_path}"
done
for x5093_path in `find ${root_directory} -type f -name "*.pem" 2>/dev/null | awk 'BEGIN{FS=OFS="/"}{NF--; print}'| uniq`; do
	echo "  ${x5093_path}"
done
echo
