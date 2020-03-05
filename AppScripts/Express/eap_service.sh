#!/usr/bin/env bash

#
#
#
# contact: shane.reddy@ttiinc.com for any queries or requests.
# name: eap_service.sh
# version: 1.0.0v
# modifications: initial version (12/31/2019)
#
#
# dependencies: bash and EAP on SystemD.
# explanation: this is the executable script that will be called by SystemD service during reboot and start/stop.
#
#
#

# Variables.
EAP_BIN="/apps/jboss-eap-7.2/"
EAP_USER="jboss"
EAP_SCRIPTS="/tti/bin"

# Functions

function start {
    ${EAP_SCRIPTS}/startEAP72.sh --all
}

function stop {
    ${EAP_SCRIPTS}/stopEAP72.sh --all
}

# Main.
case $1 in
    start|stop) "$1" ;;
esac

#end_eap_service.sh