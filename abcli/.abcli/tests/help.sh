#! /usr/bin/env bash

function test_abcli_help() {
    local options=$1

    local module
    for module in \
        "abcli"; do
        abcli_eval ,$options \
            $module help
        [[ $? -ne 0 ]] && return 1
    done

    return 0
}
