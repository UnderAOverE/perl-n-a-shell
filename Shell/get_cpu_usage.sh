#!/bin/bash

#
#
#
# get_cpu_usage.sh
# r2d2c3p0
# 05/23/2019
# 1.0v
# initial run for 5 seconds only.
#

# variables.
number_of_times=10;
delay=0.5;

# main.
if [[ ${#} -eq 1 ]]; then
	process_pid=${1}
	ps -ef | grep ${process_pid} | grep -v grep >/dev/null 2>&1
	if [[ $? -eq 0 ]]; then
		calculator_str=$(top -d ${delay} -b -n ${number_of_times} -p ${process_pid} \
			| grep ${process_pid} \
				| sed -r -e "s;\s\s*; ;g" -e "s;^ *;;" \
					| cut -d' ' -f9 \
						| tr '\n' '+' \
							| sed -r -e "s;(.*)[+]$;\1;" -e "s/.*/scale=2;(&)\/${number_of_times}/"); \
								 percentage_cpu=$(echo "${calculator_str}" | bc -l);
		echo "  Process: ${process_pid}"
		echo "    CPU: ${percentage_cpu}"
		echo "     Total Time: $(perl -E "say $delay*$number_of_times") seconds"
		exit 0
	else
		echo "  [ERROR] input process PID: ${process_pid} not found."
		exit 1
	fi
else
	echo "  [ERROR] usage, input process PID."
	exit 1
fi

#end_get_cpu_usage.sh
