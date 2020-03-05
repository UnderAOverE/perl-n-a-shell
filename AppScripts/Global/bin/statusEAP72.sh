#!/usr/bin/env bash

######################################################################################################################
#
# name: statusEAP72.sh
# author: Shane Reddy
# version: 1.0.0v
# dob: 01/02/2020
# explanation: Start script for EAP 7.2 servers, this will start the domain controller, host controllers and servers.
# dependencies: bash & EAP 7.2 installation.
# modifications: (01/02/2020 1.0.0v) initial version.
#
# contact: shane.reddy@ttiinc.com
#
######################################################################################################################

######################################################################################################################
# environment variables.
######################################################################################################################
export jboss_home=/apps/jboss-eap-7.2
export log_directory=/apps/logs
export script_directory=/tti

# Development, QA & Production environment variables.
export node_port=29999
export jvm_port=8230 # JVM HTTP port
export management_port=9999
export devmaster_address=10.1.63.85 # Development Master IP address
export devnode1_address=10.1.63.85 # Development Node1 IP address
export devnode2_address=10.1.63.89 # Development Node2 IP address
export server_group=ExpressDev

# default variables (time is in seconds)
host_name=$(hostname)
fid_name="jboss"

# Tool switches.
got_logger=1
got_verbose=1
got_debug=0

######################################################################################################################
# functions.
######################################################################################################################
function clear_screen {
    { clear; echo; echo;      } 2>/dev/null  ||
    { tput clear; echo; echo; } 2>/dev/null  ||
    for empty_space in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 ; do
        echo
    done
}

#function Echo {
#    echo "$(date +[%m/%d/%Y\ %H:%M:%S\ %Z])|$(hostname)|${@}" | tee -a ${log_directory}/statusEAP72.log
#}

function Echo {
    debug_messages=${1}
    show_me=${2}
    log_me=${3}
    log_level=${4}
    Message=${5}
    date_recorded=$(date +[%m/%d/%Y\ %H:%M:%S\ %Z])
    host_name=$(hostname -f)
    if [[ ${show_me} -eq 1 ]]; then
       if [[ ${log_level} -eq 0 ]]; then
          if [[ ${debug_messages} -eq 1 ]]; then
             echo "    (debug) ${Message}"
          fi
       elif [[ ${log_level} -eq 1 ]]; then
          echo "    (INFO) ${Message}"
       elif [[ ${log_level} -eq 2 ]]; then
          echo "    (WARN) ${Message}"
       elif [[ ${log_level} -eq 3 ]]; then
          echo "    (ERROR) ${Message}"
       elif [[ ${log_level} -eq 4 ]]; then
          echo "    (FATAL) ${Message}"
       else
          echo "    (??) ${Message}"
       fi
    fi
    if [[ ${log_me} -eq 1 ]]; then
       if [[ ${log_level} -eq 0 ]]; then
          if [[ ${debug_messages} -eq 1 ]]; then
             echo "${date_recorded}|${host_name}|debug| ${Message}" >> ${log_directory}/statusEAP72.log
          fi
       elif [[ ${log_level} -eq 1 ]]; then
          echo "${date_recorded}|${host_name}|INFO| ${Message}" >> ${log_directory}/statusEAP72.log
       elif [[ ${log_level} -eq 2 ]]; then
          echo "${date_recorded}|${host_name}|WARN| ${Message}" >> ${log_directory}/statusEAP72.log
       elif [[ ${log_level} -eq 3 ]]; then
          echo "${date_recorded}|${host_name}|ERROR| ${Message}" >> ${log_directory}/statusEAP72.log
       elif [[ ${log_level} -eq 4 ]]; then
          echo "${date_recorded}|${host_name}|FATAL| ${Message}" >> ${log_directory}/statusEAP72.log
       else
          echo "${date_recorded}|${host_name}|??| ${Message}" >> ${log_directory}/statusEAP72.log
       fi
    fi
}

function check_master {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_master'."
    timeout 1 bash -c "</dev/tcp/${devmaster_address}/${management_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Domain Controller (devmaster) @ ${devmaster_address}:${management_port} is up."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Domain Controller (devmaster) @ ${devmaster_address}:${management_port} is down."
    fi
}

function check_servers {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_servers'."
    timeout 1 bash -c "</dev/tcp/${devnode1_address}/${jvm_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "server (${server_group}) @ ${devnode1_address}:${jvm_port} is up."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "server (${server_group}) @ ${devnode1_address}:${jvm_port} is down."
    fi
    timeout 1 bash -c "</dev/tcp/${devnode2_address}/${jvm_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "server (${server_group}) @ ${devnode2_address}:${jvm_port} is up."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "server (${server_group}) @ ${devnode2_address}:${jvm_port} is down."
    fi
}

function check_hosts {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_hosts'."
    timeout 1 bash -c "</dev/tcp/${devnode1_address}/${node_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Host Controller (dev_node1) is up."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Host Controller (dev_node1) is down."
    fi
    timeout 1 bash -c "</dev/tcp/${devnode2_address}/${node_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Host Controller (dev_node2) is up."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Host Controller (dev_node2) is down."
    fi

}

function print_help {
    echo ""
    echo "      ./statusEAP72.sh.sh --master or --node or --servergroup or --application or --version or --help or --info"
    echo "          shortcut convention: ./statusEAP72.sh.sh [-m/ -n/ -sg/ -app/ -v/ -h/ -i]"
    echo ""
    echo "      --master|-m --> performs status operation on Domain Controller aka Master node."
    echo "      --node|-n --> performs status operation on Host Controller aka Slave node."
    echo "      --servergroup|-sg --> performs status operation on server(s)/ JVM(s) inside the Server Group '${server_group}'."
    echo "      --application|-app --> performs status operation on application deployed on '${server_group}'."
    echo "          above app status is HTTP return codes which are mapped to 1 for unavaiable and 0 avaiable."
    echo ""
    echo "      '--all' or '-a' will combine all the above targets."
    echo ""
    echo "      Below switches are used for logging purposes"
    echo "      '--noverbose|-nv' will disable STDOUT and only a warning message will be printed alerting the user."
    echo "      '--nolog|-nl' will disable logging and a warning message will be printed alerting the user."
    echo "      '--debug|-d' enables debug mode for logging."
    echo ""
    echo "      Below operations will force the program to exit immediately, do not use with any other operations!"
    echo "          --help|-h prints this information."
    echo "          --info|-i prints meta information of the tool."
    echo "          --version|-v prints tool version."
    echo ""
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '0'"
    exit 0
}

function check_if_app_is_ready {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_if_app_is_ready'."
    dev1_return=$(python ${script_directory}/py/app_ready.py "Express Development 1" "http://10.1.63.85:8230/httpSession/login.html" "404")
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "dev1_return=${dev1_return}."
    dev2_return=$(python ${script_directory}/py/app_ready.py "Express Development 2" "http://10.1.63.89:8230/httpSession/login.html" "404")
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "dev1_return=${dev1_return}."
    if [[ ${dev1_return} -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Application is up and ready now on 'devnode1', URL below."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Application is NOT ready on 'devnode1', URL below."
    fi
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "http://10.1.63.85:8230/httpSession/login.html."
    if [[ ${dev2_return} -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Application is up and ready now on 'devnode2', URL below."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Application is NOT ready on 'devnode2', URL below."
    fi
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "http://10.1.63.89:8230/httpSession/login.html."
}

######################################################################################################################
# main.
######################################################################################################################
clear_screen
echo "" >> ${log_directory}/statusEAP72.log; echo "---" >> ${log_directory}/statusEAP72.log
if [[ $# -eq 0 ]]; then
    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Usage error, refer below help information."
    print_help
else
    input_arguments="${@}"
    for i_a in $(echo ${input_arguments}); do
        case ${i_a} in
            --info|-i)
                    sed -n '4,14'p $0 | sed 's/#/        /'
                    shift;
                    exit 0
                    ;;
            --version|-v)
                    sed -n '7'p $0 | awk '{print $3}'
                    shift;
                    exit 0
                    ;;
            --nolog|-nl)
                    got_logger=0
                    echo " (WARNING) logging disabled by user."
                    ;;
            --debug|-d)
                    got_debug=1
                    echo " (INFO) 'debug' enabled by user."
                    ;;
            --noverbose|-nv)
                    got_verbose=0
                    echo " (WARNING) verbose output disabled by user."
                    ;;
            --help|-h)
                    print_help
                    shift;
                    ;;
            *)
                    dipper="doppleganger";
                    ;;
        esac
    done
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "tool starting with below values,"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "jboss_home=${jboss_home}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "log_directory=${log_directory}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "script_directory=${script_directory}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "node_port=${node_port}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "jvm_port=${jvm_port}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "management_port=${management_port}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "devmaster_address=${devmaster_address}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "devnode1_address=${devnode1_address}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "devnode2_address=${devnode2_address}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "server_group=${server_group}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host_name=${host_name}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "fid_name=${fid_name}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "application_start_time=${application_start_time}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_logger=${got_logger}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_verbose=${got_verbose}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_debug=${got_debug}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "${@}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'status' operation begin on '${host_name}'."
    while [[ $# -ne 0 ]]; do
        case ${1} in
                    --node|-n)
                            check_hosts
                            shift;
                            ;;
                    --master|-m)
                            check_master
                            shift;
                            ;;
                    --servergroup|-sg)
                            check_servers
                            shift;
                            ;;
                    --all|-a)
                            check_master
                            check_hosts
                            check_servers
                            check_if_app_is_ready
                            shift;
                            ;;
                    --application|-app)
                            check_if_app_is_ready
                            shift;
                            ;;
                    --nolog|-nl)
                            shift;
                            ;;
                    --debug|-d)
                            shift;
                            ;;
                    --noverbose|-nv)
                            shift;
                            ;;
                    *)
                            Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Invalid input argument ${1}!"
                            print_help;
                            ;;
        esac
    done
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'status' operation completed on '${host_name}'."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '0'"
    echo;exit 0
fi

#end_statusEAP72.sh