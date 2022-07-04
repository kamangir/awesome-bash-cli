#! /usr/bin/env bash

function $abcli_name() {
    abcli $@
}

function abcli() {
    local task=$(abcli_unpack_keyword $1 help)

    if [[ $(type -t abcli_$task) == "function" ]] ; then
        abcli_$task ${@:2}
    else
        abcli_log_error "-abcli: $task: command not found."
    fi
}

function abcli_get_version() {
    export abcli_version=$(python3 -c "import abcli; print(abcli.version)")
}
