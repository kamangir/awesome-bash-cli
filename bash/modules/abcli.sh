#! /usr/bin/env bash

function abc() {
    abcli $@
}

function abcli() {
    local task=$(abcli_unpack_keyword $1 help)

    local function_name=abcli_$task
    if [[ $(type -t $function_name) == "function" ]] ; then
        $function_name ${@:2}
    else
        abcli_log_error "-abcli: $task: command not found."
    fi
}

function abcli_get_version() {
    export abcli_version=$(python3 -c "import abcli; print(abcli.VERSION)")
}