#!/usr/bin/env bash

##############################################################################################################################################################################
#
#
# contact: shane.reddy@ttiinc.com for any queries or requests.
# name: get_mqconfig.sh
# version: 1.1.0v
# dob: 12/12/2019
# modifications: (12/12/2019 1.0.0v) initial version.
#                (02/25/2020 1.1.0v) Backout Queue.
#
# dependencies: IBM MQ Qmgrs.
# author: Shane Reddy
#
#
#
##############################################################################################################################################################################

##############################################################################################################################################################################
# Main.
##############################################################################################################################################################################

if [[ ${#} -eq 0 ]]; then
    echo;echo "ERROR| enter Queue Manager name!";echo
    exit 1
else
    queue_manager=${1}
    get_system=${2}
    echo;echo " -> Queue Manager: ${queue_manager}";
    echo "     --------------------------------------------------------------"
    echo "display queue(*)" | runmqsc "${queue_manager}" >/dev/null 2>&1
    [[ $? -eq 0 ]] || { echo "   -> ERROR| ${queue_manager} does not exist!" ; echo ; exit 1 ; }
    case "${get_system}" in
        --all|-a)
           listener_bundle=$(echo "display listener(*)" | runmqsc "${queue_manager}" | grep "LISTENER" | grep -v "display" | grep -v grep | awk '{print $1}')
           queue_bundle=$(echo "display queue(*)" | runmqsc "${queue_manager}" | grep "QUEUE" | grep -v "display" | grep -v grep | awk '{print $1}')
           channel_bundle=$(echo "display channel(*)" | runmqsc "${queue_manager}" | grep "CHANNEL" | grep -v "display" | grep -v grep | awk '{print $1}')
           ;;
        *)
           echo "      (Warning) ignoring 'SYSTEM' objects.";
           listener_bundle=$(echo "display listener(*)" | runmqsc "${queue_manager}" | grep "LISTENER" | grep -v "SYSTEM" | grep -v "display" | grep -v grep | awk '{print $1}')
           queue_bundle=$(echo "display queue(*)" | runmqsc "${queue_manager}" | grep "QUEUE" | grep -v "SYSTEM" | grep -v "display" | grep -v grep | awk '{print $1}')
           channel_bundle=$(echo "display channel(*)" | runmqsc "${queue_manager}" | grep "CHANNEL" | grep -v "SYSTEM" | grep -v "display" | grep -v grep | awk '{print $1}')
           ;;
    esac
    for queue_name in $(echo "${queue_bundle}"); do
        trimmed_queue=$(echo ${queue_name} | sed "s/QUEUE//;s/(//g;s/)//g")
        current_depth=$(echo "display queue(${trimmed_queue}) CURDEPTH" | runmqsc "${queue_manager}" | grep "CURDEPTH" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/CURDEPTH//;s/(//g;s/)//g;/^$/d")
        cluster_name=$(echo "display queue(${trimmed_queue}) CLUSTER" | runmqsc "${queue_manager}" | grep "CLUSTER" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/CLUSTER//;s/(//g;s/)//g;/^$/d")
        queue_type=$(echo "display queue(${trimmed_queue}) TYPE" | runmqsc "${queue_manager}" | grep "TYPE" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/TYPE//;s/(//g;s/)//g;/^$/d")
        description=$(echo "display queue(${trimmed_queue}) DESCR" | runmqsc "${queue_manager}" | grep "DESCR" | grep -v "display" | grep -v grep | sed "s/DESCR//;s/(//g;s/)//g;s/   //;/^$/d")
        get_flag=$(echo "display queue(${trimmed_queue}) GET" | runmqsc "${queue_manager}" | grep "GET" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/GET//;s/(//g;s/)//g;/^$/d")
        put_flag=$(echo "display queue(${trimmed_queue}) PUT" | runmqsc "${queue_manager}" | grep "PUT" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/PUT//;s/(//g;s/)//g;/^$/d")
        max_depth=$(echo "display queue(${trimmed_queue}) MAXDEPTH" | runmqsc "${queue_manager}" | grep "MAXDEPTH" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/MAXDEPTH//;s/(//g;s/)//g;/^$/d")
        ipprocs=$(echo "display queue(${trimmed_queue}) IPPROCS" | runmqsc "${queue_manager}" | grep "IPPROCS" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/IPPROCS//;s/(//g;s/)//g;/^$/d")
        mxmsg=$(echo "display queue(${trimmed_queue}) MAXMSGL" | runmqsc "${queue_manager}" | grep "MAXMSGL" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/MAXMSGL//;s/(//g;s/)//g;/^$/d")
        qdepthh=$(echo "display queue(${trimmed_queue}) QDEPTHHI" | runmqsc "${queue_manager}" | grep "QDEPTHHI" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/QDEPTHHI//;s/(//g;s/)//g;/^$/d")
        qdepthl=$(echo "display queue(${trimmed_queue}) QDEPTHLO" | runmqsc "${queue_manager}" | grep "QDEPTHLO" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/QDEPTHLO//;s/(//g;s/)//g;/^$/d")
        boqname=$(echo "display queue(${trimmed_queue}) BOQNAME" | runmqsc "${queue_manager}" | grep "BOQNAME" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/BOQNAME//;s/(//g;s/)//g;/^$/d")
        echo "      * Queue: ${trimmed_queue}"
        echo "          Description: ${description}"
        echo "          Type: ${queue_type}"
        echo "          Current Depth: ${current_depth}"
        echo "          Cluster: ${cluster_name}"
        echo "          GET: ${get_flag}/ PUT: ${put_flag}"
        echo "          IPPROCS: ${ipprocs}"
        echo "          MAXMSGL: ${mxmsg}/ MAXDEPTH: ${max_depth}"
        echo "          QDEPTHHI: ${qdepthh}/ QDEPTHLO: ${qdepthl}"
        echo "          BOQNAME: ${boqname}"
    done
    echo "     --------------------------------------------------------------"
    for channel_name in $(echo "${channel_bundle}"); do
        trimmed_channel=$(echo ${channel_name} | sed "s/CHANNEL//;s/(//g;s/)//g")
        channel_type=$(echo "display channel(${trimmed_channel}) CHLTYPE" | runmqsc "${queue_manager}" | grep "CHLTYPE" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/CHLTYPE//;s/(//g;s/)//g;/^$/d")
        conn_name=$(echo "display channel(${trimmed_channel}) CONNAME" | runmqsc "${queue_manager}" | grep "CONNAME" | grep -v "display" | grep -v grep | awk '{print $NF}' | sed "s/CONNAME//;s/(//;s/)//;/^$/d")
        echo "      * Channel: ${trimmed_channel}"
        echo "          Type: ${channel_type}"
        echo "          Connection: ${conn_name}"
    done
    echo "     --------------------------------------------------------------"
    for listener_name in $(echo "${listener_bundle}"); do
        trimmed_listener=$(echo ${listener_name} | sed "s/LISTENER//;s/(//g;s/)//g")
        echo "      * Listener: ${trimmed_listener}"
    done
    echo "     --------------------------------------------------------------"
    exit 0
fi

#end_get_mqconfig.sh