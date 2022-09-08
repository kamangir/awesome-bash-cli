#! /usr/bin/env bash

function abcli_repeat() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli repeat <count> <command-line>" \
            "repeat <command-line> <count> times."
        return
    fi

    local count=$1
    local command=${@:2}

    for index in $(seq $count); do
        abcli_log "$index/$count: $command"
        $command
    done
}