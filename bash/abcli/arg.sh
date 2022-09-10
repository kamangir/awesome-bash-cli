#! /usr/bin/env bash

function abcli_clarify_input() {
    local default=$2
    local arg_name=${1:-$default}

    if [ "$arg_name" == "-" ] ; then
        local arg_name=$default
    fi

    echo $arg_name
}