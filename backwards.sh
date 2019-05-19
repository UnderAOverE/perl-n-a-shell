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

---------------------------------------------------------------------------------------------------------


#!/usr/bin/ksh

while [[ $# -ne 0 ]]; do
	input_argument=${1}
	l_argument=${#input_argument}
	final_string=""
	while [[ ${l_argument} -ne 0 ]]; do
		place_holder=$(echo ${input_argument} | cut -b ${l_argument})
		l_argument=$((l_argument-=1))
		final_string="${final_string}${place_holder}"
	done
	echo ${final_string}
	shift;
done
