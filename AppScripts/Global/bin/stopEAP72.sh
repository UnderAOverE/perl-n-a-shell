#!/usr/bin/env bash

######################################################################################################################
#
# name: stopEAP72.sh
# author: Shane Reddy
# version: 1.2.0v
# dob: 12/23/2019
# explanation: Stop script for EAP 7.2 servers, this will stop the domain controller, host controllers and servers.
# dependencies: bash & EAP 7.2 installation.
# modifications: (12/23/2019 1.0.0v) initial version.
#                (12/27/2019 1.1.0v) added 'check_if_app_is_down'.
#                (01/02/2020 1.2.0v) added 'Echo'.
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
application_stop_time=60

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
#    echo "$(date +[%m/%d/%Y\ %H:%M:%S\ %Z])|$(hostname)|${@}" | tee -a ${log_directory}/stopEAP72.log
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
             echo "${date_recorded}|${host_name}|debug| ${Message}" >> ${log_directory}/stopEAP72.log
          fi
       elif [[ ${log_level} -eq 1 ]]; then
          echo "${date_recorded}|${host_name}|INFO| ${Message}" >> ${log_directory}/stopEAP72.log
       elif [[ ${log_level} -eq 2 ]]; then
          echo "${date_recorded}|${host_name}|WARN| ${Message}" >> ${log_directory}/stopEAP72.log
       elif [[ ${log_level} -eq 3 ]]; then
          echo "${date_recorded}|${host_name}|ERROR| ${Message}" >> ${log_directory}/stopEAP72.log
       elif [[ ${log_level} -eq 4 ]]; then
          echo "${date_recorded}|${host_name}|FATAL| ${Message}" >> ${log_directory}/stopEAP72.log
       else
          echo "${date_recorded}|${host_name}|??| ${Message}" >> ${log_directory}/stopEAP72.log
       fi
    fi
}

function check_servers {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_servers'."
    timeout 1 bash -c "</dev/tcp/${devnode1_address}/${jvm_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        timeout 1 bash -c "</dev/tcp/${devnode2_address}/${jvm_port}" >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "'check_servers' returning '0'"
            return 0
        fi
    fi
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "'check_servers' returning '1'"
    return 1
}

function check_hosts {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_hosts'."
    timeout 1 bash -c "</dev/tcp/${devnode1_address}/${node_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        timeout 1 bash -c "</dev/tcp/${devnode2_address}/${node_port}" >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "'check_hosts' returning '0'"
            return 0
        fi
    fi
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "'check_hosts' returning '1'"
    return 1
}

function stop_master {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'stop_master'."
    case "${host_name}" in
        # Express EAP 7.2 Development Servers (devmaster)
        txjbsd05)
            timeout 1 bash -c "</dev/tcp/${devmaster_address}/${management_port}" >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopping Domain Controller on 'devmaster'..."
                sleep 1
                sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /host=devmaster:shutdown' >/dev/null 2>&1
                sleep 10
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "master 'java' process check inside ${host_name}."
                ps -ef | grep java | grep host-master.xml | grep -v grep >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Domain Controller on 'devmaster' using CLI!"
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "killing PID of Domain Controller (devmaster)..."
                    for controller_pid in $(ps -ef | grep java | grep host-master.xml | grep -v grep | awk '{print $2}'); do
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Controller PID '${controller_pid}' killed."
                        kill -9 ${controller_pid}
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside controller pid 'for' loop."
                    done
                    sleep 5
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "master 'java' process check again on ${host_name}."
                    ps -ef | grep java | grep host-master.xml | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop & kill Domain Controller on 'devmaster'!"
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team."
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                        exit 1
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Killed Domain Controller on 'devmaster'."
                    fi
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopped Domain Controller on 'devmaster'."
                fi
            else
                Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Domain Controller on 'devmaster' @ ${host_name}:${management_port} is not running."
            fi
            ;;
          # Exit for all other hosts
        *)
            Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Please login to 'txjbsd05.ttiinc.com' to stop the Master!"
            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Domain Controller runs on above host."
            ;;
    esac
}

function stop_host {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'stop_host'."
    hkill_flag=0
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "hkill_flag=${hkill_flag}."
    case "${host_name}" in
            # Express EAP 7.2 Development Servers (devnode1)
            txjbsd05)
                timeout 1 bash -c "</dev/tcp/${host_name}/${node_port}" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    timeout 1 bash -c "</dev/tcp/${devmaster_address}/${management_port}" >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopping Host Controller on 'devnode1'..."
                        sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /host=devnode1:shutdown' >/dev/null 2>&1
                        check_if_app_is_down 0
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "The Master (Domain Controller) is not running, cannot use CLI!"
                    fi
                    hkill_flag=1
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "hkill_flag=${hkill_flag}."
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Host Controller on 'devnode1' @ ${host_name}:${node_port} is not running."
                fi
                if [[ ${hkill_flag} -eq 1 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host 'java' process check inside ${host_name}."
                    ps -ef | grep java | grep host-slave.xml | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        for controller_pid in $(ps -ef | grep java | grep host-slave.xml | grep -v grep | awk '{print $2}'); do
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Controller PID '${controller_pid}' killed."
                            kill -9 ${controller_pid}
                            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside controller pid (host) 'for' loop."
                        done
                        sleep 5
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host 'java' process check again on ${host_name}."
                        ps -ef | grep java | grep host-slave.xml | grep -v grep >/dev/null 2>&1
                        if [[ $? -eq 0 ]]; then
                            Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Host Controller on 'devnode1'!"
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team."
                            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                            exit 1
                        else
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Killed Host Controller on 'devnode1'."
                        fi
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopped Host Controller on 'devnode1'."
                    fi
                fi
                ;;
            # Express EAP 7.2 Development Servers (devnode2)
            txjbsd06)
                timeout 1 bash -c "</dev/tcp/${host_name}/${node_port}" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    timeout 1 bash -c "</dev/tcp/${devmaster_address}/${management_port}" >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopping Host Controller on 'devnode2'..."
                        sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /host=devnode2:shutdown' >/dev/null 2>&1
                        check_if_app_is_down 0
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "The Master (Domain Controller) is not running, cannot use CLI!"
                    fi
                    hkill_flag=1
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "hkill_flag=${hkill_flag}."
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Host Controller on 'devnode2' @ ${host_name}:${node_port} is not running."
                fi
                if [[ ${hkill_flag} -eq 1 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host 'java' process check inside ${host_name}."
                    ps -ef | grep java | grep host-slave.xml | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        for controller_pid in $(ps -ef | grep java | grep host-slave.xml | grep -v grep | awk '{print $2}'); do
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Controller PID '${controller_pid}' killed."
                            kill -9 ${controller_pid}
                            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside controller pid (host) 'for' loop."
                        done
                        sleep 5
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host 'java' process check again on ${host_name}."
                        ps -ef | grep java | grep host-slave.xml | grep -v grep >/dev/null 2>&1
                        if [[ $? -eq 0 ]]; then
                            Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Host Controller on 'devnode2'!"
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team."
                            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                            exit 1
                        else
                            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Killed Host Controller on 'devnode2'."
                        fi
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopped Host Controller on 'devnode2'."
                    fi
                fi
                ;;
            # Exit for all other hosts
            *)
              Echo ${got_debug} ${got_verbose} ${got_logger} 3 "unknown host[$(hostname)]!"
              Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
              exit 1
              ;;
    esac
}

function stop_servergroup {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'stop_servergroup'."
    kill_flag=0
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "kill_flag=${kill_flag}."
    check_servers
    if [[ $? -eq 0 ]]; then
        check_hosts
        if [[ $? -eq 0 ]]; then
            timeout 1 bash -c "</dev/tcp/${devmaster_address}/${management_port}" >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopping Server Group '${server_group}'..."
                sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /server-group=${server_group}:stop-servers' >/dev/null 2>&1
                sleep 1
                check_if_app_is_down 1
                kill_flag=1
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "kill_flag=${kill_flag}."
            else
                Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Domain Controller on 'devmaster' @ ${host_name}:${management_port} is not running."
                kill_flag=1
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "kill_flag=${kill_flag}."
            fi
        else
            Echo ${got_debug} ${got_verbose} ${got_logger} 2 "cannot perform server group 'stop' operation"
            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "All the hosts inside the server group '${server_group}' should be up!"
        fi
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "'${server_group}' is not running."
    fi
    if [[ ${kill_flag} -eq 1 ]]; then
        case "${host_name}" in
            # Express EAP 7.2 Development Servers (devnode1)
            txjbsd05)
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "server 'java' process check inside ${host_name}."
                ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Server Group '${server_group}' on 'devnode1' using CLI!"
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "killing '${server_group}' JVM PIDs on 'devnode1'..."
                    for jvm_pid in $(ps -ef | grep java | grep grep org.jboss.as.server | grep -v grep | awk '{print $2}'); do
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "JVM PID '${jvm_pid}' killed."
                        kill -9 ${jvm_pid}
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside controller pid (servergroup) 'for' loop."
                    done
                    sleep 5
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "server 'java' process check again on ${host_name}."
                    ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Server Group '${server_group}' JVM on 'devnode1'!"
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team."
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                        exit 1
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Killed Server Group '${server_group}' JVM on 'devnode1'."
                    fi
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopped Server Group '${server_group}' JVM on 'devnode1'."
                fi
                ;;
            # Express EAP 7.2 Development Servers (devnode2)
            txjbsd06)
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "server 'java' process check inside ${host_name}."
                ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Server Group '${server_group}' on 'devnode2' using CLI!"
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "killing '${server_group}' JVM PIDs on 'devnode2'..."
                    for jvm_pid in $(ps -ef | grep java | grep grep org.jboss.as.server | grep -v grep | awk '{print $2}'); do
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "JVM PID '${jvm_pid}' killed."
                        kill -9 ${jvm_pid}
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside controller pid (servergroup) 'for' loop."
                    done
                    sleep 5
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "server 'java' process check again on ${host_name}."
                    ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Failed to stop Server Group '${server_group}' JVM on 'devnode2'!"
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team."
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                        exit 1
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Killed Server Group '${server_group}' JVM on 'devnode2'."
                    fi
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Stopped Server Group '${server_group}' JVM on 'devnode2'."
                fi
                ;;
            # Exit for all other hosts
            *)
                Echo ${got_debug} ${got_verbose} ${got_logger} 3 "unknown host[$(hostname)]!"
                Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                exit 1
                ;;
        esac
    fi
}

function print_help {
    echo ""
    echo "      ./stopEAP72.sh.sh --master or --node or --servergroup or --version or --help or --info"
    echo "          shortcut convention: ./stopEAP72.sh.sh [-m/ -n/ -sg/ -v/ -h/ -i]"
    echo ""
    echo "      --master|-m --> performs stop operation on Domain Controller aka Master node."
    echo "           Execute this operation only the DC host 'txjbsd05.ttiinc.com'"
    echo "      --node|-n --> performs stop operation on Host Controller aka Slave node."
    echo "           Above operation also stops the server group (+JVMs)."
    echo "      --servergroup|-sg --> performs stop operation on server(s)/ JVM(s) inside the Server Group '${server_group}'."
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

function check_if_app_is_down {
    servergroup_stop=${1}
    stop_counter=0
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_if_app_is_down'."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "stop_counter=${stop_counter}."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "servergroup_stop=${servergroup_stop}."
    while true; do
        if [[ ${servergroup_stop} -eq 1 ]]; then
            Echo ${got_debug} ${got_verbose} ${got_logger} 1 "checking the status of server on 'devnode1'..."
            sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /host=devnode1/server=txjbsd05_s01:read-attribute\(name=server-state\)' | grep "STOPPED" >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stopped now on 'devnode1'."
                Echo ${got_debug} ${got_verbose} ${got_logger} 1 "checking the status of server on 'devnode2'..."
                sudo -H -E -u ${fid_name} bash -c '${jboss_home}/bin/jboss-cli.sh --connect controller=${devmaster_address}:${management_port} /host=devnode2/server=txjbsd06_s01:read-attribute\(name=server-state\)' | grep "STOPPED" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stopped now on 'devnode2'."
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "check_if_app_is_down break."
                    break;
                else
                    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stop in-progress on 'devnode2'."
                fi
            else
                Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stop in-progress on 'devnode1'."
            fi
        else
            case "${host_name}" in
                # Express EAP 7.2 Development Servers (devnode1)
                txjbsd05)
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "(check_if_app_is_down) server 'java' process check inside ${host_name}."
                    ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stop in-progress on 'devnode1'."
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stopped now on 'devnode1'."
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "check_if_app_is_down break."
                        break;
                    fi
                    ;;
                # Express EAP 7.2 Development Servers (devnode2)
                txjbsd06)
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "(check_if_app_is_down) server 'java' process check inside ${host_name}."
                    ps -ef | grep java | grep "org.jboss.as.server" | grep -v grep >/dev/null 2>&1
                    if [[ $? -eq 0 ]]; then
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stop in-progress on 'devnode2'."
                    else
                        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server (JVM) stopped now on 'devnode2'."
                        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "check_if_app_is_down break."
                        break;
                    fi
                    ;;
                # Exit for all other hosts
                *)
                    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "unknown host[$(hostname)]!"
                    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
                    exit 1
                    ;;
            esac
        fi
        stop_counter=$((stop_counter+1))
        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "+stop_counter=${stop_counter}."
        if [[ ${stop_counter} -eq 4 ]]; then
            Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Stop operation took more than 3 minutes!"
            Echo ${got_debug} ${got_verbose} ${got_logger} 0 "check_if_app_is_down break."
            break;
        fi
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "status check again in ${application_stop_time} seconds..."
        Echo ${got_debug} ${got_verbose} ${got_logger} 0 "sleeping for ${application_stop_time} seconds."
        sleep ${application_stop_time}
    done
}

######################################################################################################################
# main.
######################################################################################################################
clear_screen
echo "" >> ${log_directory}/stopEAP72.log; echo "---" >> ${log_directory}/stopEAP72.log
if [[ $# -eq 0 ]]; then
    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Usage error, refer below help information."
    print_help
else
    input_arguments="${@}"
    for i_a in $(echo ${input_arguments}); do
        case ${i_a} in
            --info|-i)
                    sed -n '4,16'p $0 | sed 's/#/        /'
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
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'stop' operation begin on '${host_name}'."
    while [[ $# -ne 0 ]]; do
        case ${1} in
                    --node|-n)
                            stop_host
                            shift;
                            ;;
                    --master|-m)
                            stop_master
                            shift;
                            ;;
                    --servergroup|-sg)
                            stop_servergroup
                            shift;
                            ;;
                    --all|-a)
                            stop_servergroup
                            sleep 1
                            stop_host
                            sleep 1
                            stop_master
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
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'stop' operation completed on '${host_name}'."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '0'"
    echo;exit 0
fi

#end_stopEAP72.sh
