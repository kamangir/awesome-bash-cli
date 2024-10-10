#! /usr/bin/env bash

function abcli() {
    local task=$(abcli_unpack_keyword $1 version)

    local function_name=abcli_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
    else
        abcli_log_error "abcli: $task: command not found."
        return 1
    fi
}

function abcli_version() {
    echo $abcli_fullname
}

function abcli_help() {
    abcli_log $abcli_fullname
}

abcli_env_dot_load \
    caller,filename=config.env,suffix=/../..
