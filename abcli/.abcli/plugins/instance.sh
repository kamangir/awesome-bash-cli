#! /usr/bin/env bash

function abcli_instance() {
    local task=$(abcli_unpack_keyword $1 list)

    local function_name=abcli_instance_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    abcli_log_error "@instance: $task: command not found."
    return 1
}

abcli_source_caller_suffix_path /instance
