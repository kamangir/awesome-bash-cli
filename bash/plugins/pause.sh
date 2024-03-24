#! /usr/bin/env bash

function abcli_pause() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "abcli pause [dryrun|message=<message>]" \
            "show <message> and pause for key press."
        return
    fi

    if [[ $(abcli_option_int "$options" dryrun 0) == 1 ]]; then
        return
    fi

    local message=$(abcli_option "$options" message "press any key to continue...")

    abcli_log "$message"
    read -p ""
}
