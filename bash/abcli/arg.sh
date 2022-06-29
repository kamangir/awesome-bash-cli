#! /usr/bin/env bash

function abcli_clarify_arg() {
    local arg_name=$1
    local default=$2

    if [ -z "$arg_name" ] || [ "$arg_name" == "-" ] ; then
        local arg_name=$default
    fi

    echo $arg_name
}