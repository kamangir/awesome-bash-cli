#! /usr/bin/env bash

function abcli_env() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name env [keyword_1]" \
            "show environment variables [relevant to keyword_1]."
        return
    fi

    env | grep abcli_ | grep "$1" | sort
}