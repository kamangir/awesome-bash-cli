#! /usr/bin/env bash

function abcli_pypi() {
    local task=$(abcli_unpack_keyword $1 help)

    local options=$2
    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [[ "$task" == "help" ]]; then
        abcli_pypi_browse "$1,$2"
        abcli_pypi_build "$1,$2"
        abcli_pypi_install "$1,$2"
        return
    fi

    local function_name=abcli_pypi_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    abcli_log_error "-$plugin_name: pypi: $task: command not found."
    return 1
}

abcli_source_path - caller,suffix=/pypi
