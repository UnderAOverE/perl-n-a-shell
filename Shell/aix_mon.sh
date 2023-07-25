#!/bin/bash

function get_cpu_usage() {
    cpu_usage=$(sar -u 1 1 | awk 'NR>3{print $2,$3,$4,$5}')
    echo "$cpu_usage"
}

function get_memory_usage() {
    memory_usage=$(svmon -G -O unit=MB | awk 'NR>2{print $9,$3}')
    echo "$memory_usage"
}

function print_cpu_usage() {
    local cpu_usage_data="$1"
    if [[ -n "$cpu_usage_data" ]]; then
        echo -e "\nCPU Usage:"
        echo -e "CPU   User%   System%   Idle%"
        echo "$cpu_usage_data"
    else
        echo "Failed to get CPU usage data."
    fi
}

function print_memory_usage() {
    local memory_usage_data="$1"
    if [[ -n "$memory_usage_data" ]]; then
        echo -e "\nMemory Usage:"
        echo -e "Process Name                    Memory Used (MB)"
        echo "$memory_usage_data"
    else
        echo "Failed to get memory usage data."
    fi
}

while true; do
    cpu_usage=$(get_cpu_usage)
    memory_usage=$(get_memory_usage)

    print_cpu_usage "$cpu_usage"
    print_memory_usage "$memory_usage"

    sleep 5 # Adjust the interval as needed
done
