#! /usr/bin/env bash

function abcli() {
    local task=$(abcli_unpack_keyword $1 help)

    if [[ $(type -t abcli_$task) == "function" ]] ; then
        abcli_$task ${@:2}
    else
        abcli_log_error "-abcli: '$task': command not found."
    fi
}