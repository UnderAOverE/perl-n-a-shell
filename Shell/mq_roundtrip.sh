#!/bin/bash

# IBM MQ Connection Details
QUEUE_MANAGER="QMGR_NAME"
CHANNEL="CHANNEL_NAME"
HOST="MQ_HOST"
PORT="MQ_PORT"
QUEUE_IN="QUEUE_IN"
QUEUE_OUT="QUEUE_OUT"

# IBM MQ Connection Parameters
CONN_INFO="$HOST($PORT)"

function put_message() {
    local queue_name="$1"
    local message="$2"

    mqput "$queue_name" "$message"
}

function get_message() {
    local queue_name="$1"

    mqget "$queue_name"
}

function main() {
    while true; do
        # Send a message from QUEUE_IN to QUEUE_OUT
        message="Hello, IBM MQ!"
        put_message "$QUEUE_IN" "$message"
        sequence_number=$(echo "display qstatus($QUEUE_IN) type(handle) all" | runmqsc $QUEUE_MANAGER | grep "CURDEPTH" | awk '{print $NF}')
        echo "Sent: Sequence Number $sequence_number - $message"

        # Receive the message from QUEUE_OUT
        received_message=$(get_message "$QUEUE_OUT")
        sequence_number=$(echo "display qstatus($QUEUE_OUT) type(handle) all" | runmqsc $QUEUE_MANAGER | grep "CURDEPTH" | awk '{print $NF}')
        echo "Received: Sequence Number $sequence_number - $received_message"

        sleep 5  # Wait for 5 seconds before sending the next message
    done
}

trap 'exit 0' SIGINT SIGTERM

main
