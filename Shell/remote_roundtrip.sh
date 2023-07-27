#!/bin/bash

# Local Queue Manager Details
LOCAL_QMGR="LOCAL_QMGR_NAME"
LOCAL_CHANNEL="LOCAL_CHANNEL_NAME"
LOCAL_HOST="LOCAL_MQ_HOST"
LOCAL_PORT="LOCAL_MQ_PORT"
LOCAL_QUEUE_IN="LOCAL_QUEUE_IN"
LOCAL_QUEUE_OUT="LOCAL_QUEUE_OUT"

# Remote Queue Manager Details
REMOTE_QMGR="REMOTE_QMGR_NAME"
REMOTE_CHANNEL="REMOTE_CHANNEL_NAME"
REMOTE_HOST="REMOTE_MQ_HOST"
REMOTE_PORT="REMOTE_MQ_PORT"
REMOTE_QUEUE_IN="REMOTE_QUEUE_IN"
REMOTE_QUEUE_OUT="REMOTE_QUEUE_OUT"

# IBM MQ Connection Parameters
LOCAL_CONN_INFO="$LOCAL_HOST($LOCAL_PORT)"
REMOTE_CONN_INFO="$REMOTE_HOST($REMOTE_PORT)"

function put_message() {
    local qmgr="$1"
    local queue_name="$2"
    local message="$3"

    echo "$message" | mqput -m "$qmgr" "$queue_name"
}

function get_message() {
    local qmgr="$1"
    local queue_name="$2"

    mqget -m "$qmgr" "$queue_name"
}

function main() {
    while true; do
        # Send a message from LOCAL_QUEUE_IN to REMOTE_QUEUE_IN
        message="Hello, IBM MQ! - Local to Remote"
        put_message "$LOCAL_QMGR" "$LOCAL_QUEUE_IN" "$message"
        local_sequence_number=$(echo "display qstatus($LOCAL_QUEUE_IN) type(handle) all" | runmqsc $LOCAL_QMGR | grep "CURDEPTH" | awk '{print $NF}')
        echo "Sent: Local Queue Sequence Number $local_sequence_number - $message"

        # Receive the message from REMOTE_QUEUE_OUT to LOCAL_QUEUE_OUT
        received_message=$(get_message "$REMOTE_QMGR" "$REMOTE_QUEUE_OUT")
        remote_sequence_number=$(echo "display qstatus($REMOTE_QUEUE_OUT) type(handle) all" | runmqsc $REMOTE_QMGR | grep "CURDEPTH" | awk '{print $NF}')
        echo "Received: Remote Queue Sequence Number $remote_sequence_number - $received_message"

        sleep 5  # Wait for 5 seconds before sending the next message
    done
}

trap 'exit 0' SIGINT SIGTERM

main
