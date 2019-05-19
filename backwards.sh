#!/usr/bin/ksh

if [[ $# -eq 0 ]]; then
	echo "Enter something!"
	exit 1
else
	input_argument=${@}
	reversed=""
	for i_character in $(echo ${input_argument} | grep -o .); do
		reversed="${i_character}${reversed}"
	done
	echo "${input_argument} backwards is: ${reversed}"
fi
