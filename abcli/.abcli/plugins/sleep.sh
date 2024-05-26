#! /usr/bin/env bash

function abcli_sleep() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "@sleep seconds=<seconds>" \
            "sleep seconds=<seconds>"
        return
    fi

    local seconds=$(abcli_option "$options" seconds 3)

    abcli_log_local "sleeping for $seconds s ... (^C to stop)"
    sleep $seconds
}
