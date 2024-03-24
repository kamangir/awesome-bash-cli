#! /usr/bin/env bash

function abcli_pause() {
    local message=${1:-press any key to continue...}

    if [ "$message" == help ]; then
        abcli_show_usage "abcli pause <message>" \
            "show <message> and pause for key press."
        return
    fi

    abcli_log "$message"
    read -p ""
}
