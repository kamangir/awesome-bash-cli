#! /usr/bin/env bash

function abcli_sleep() {
    local seconds=${1:-3}

    if [ "$seconds" == help ]; then
        abcli_show_usage "abcli sleep <seconds>" \
            "sleep <seconds>"
        return
    fi

    abcli_log_local "pausing for $seconds s ... (Ctrl+C to stop)"
    sleep $seconds
}
