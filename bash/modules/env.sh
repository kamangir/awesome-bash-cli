#! /usr/bin/env bash

function abcli_env() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli env [keyword]" \
            "show environment variables [relevant to keyword]."
        abcli_show_usage "abcli env memory" \
            "show memory status."
        return
    fi

    if [ "$task" == memory ] ; then
        grep MemTotal /proc/meminfo
        return
    fi

    env | grep abcli_ | grep "$1" | sort
}