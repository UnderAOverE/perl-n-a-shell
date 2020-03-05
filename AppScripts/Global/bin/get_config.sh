#!/usr/bin/env bash

#
#
#
# contact: shane.reddy@ttiinc.com for any queries or requests.
# name: get_config.sh
# version: 1.0.0v
# modifications: initial version (11/21/2019)
# details: prints the servers, groups, hosts and applications deployed in the environment.
#
#
#

#############################################################################################################################################################################
# Environment variables.
#############################################################################################################################################################################
cli_path="/apps/jbossEAP/jboss-eap-6.4/bin"
controller_ip="10.1.63.33"
controller_port=9999
machine_name=$(hostname -f)
script_name="get_config.sh"

#############################################################################################################################################################################
# Functions
#############################################################################################################################################################################
function get_hosts {
    ${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} \
    --commands=":read-children-names(child-type=host)" |\
    egrep -v "domain|result|outcome|\]|\[|\{|\}" |\
    sed "s/\,//g;s/\"//g;s/        //g"
}

#############################################################################################################################################################################
# Main
#############################################################################################################################################################################

for app_deployed in $(${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} --commands="ls /deployment"); do
    for host_name in $(get_hosts); do
        for server in $(${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} --commands="ls host=${host_name}/server-config"); do
            ${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} --commands="/host=${host_name}/server=${server}:read-attribute(name=server-state)" | grep -q "success"
            if [[ $? -eq 0 ]]; then
                server_group=$(${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} --commands="/host=${host_name}/server=${server}:read-attribute(name=server-group)" \
                | egrep -v "outcome|\]|\[|\{|\}" \
                | awk '{print $NF}' \
                |sed "s/\,//g;s/\"//g;s/        //g")
                ${cli_path}/jboss-cli.sh --connect controller=${controller_ip}:${controller_port} --commands="/host=${host_name}/server=${server}/deployment=${app_deployed}:read-attribute(name=status)" | grep -q "success"
                if [[ $? -eq 0 ]]; then
                    #echo "-> `date +[%m/%d/%Y/%H:%M:%S/%Z]` | ${script_name} | ${machine_name} | Server: ${server}/ Server Group: ${server_group}/ Host: ${host_name}/ Application: ${app_deployed}"
					echo "  Machine: ${machine_name}"
					echo "    Group: ${server_group}"
					echo "      Host: ${host_name}"
					echo "        Instance: ${server}"
					echo "          Application: ${app_deployed}"
                fi
            fi
        done
    done
done

#end_get_config.sh