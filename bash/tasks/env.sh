#! /usr/bin/env bash

function abcli_env() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name env [keyword]" \
            "show environment variables [relevant to keyword]."
        return
    fi

    env | grep abcli_ | grep "$1" | sort
}