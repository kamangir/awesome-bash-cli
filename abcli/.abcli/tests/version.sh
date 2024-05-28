#! /usr/bin/env bash

function test_abcli_version() {
    local options=$1

    abcli_eval ,$options \
        "abcli version ${@:2}"

    return 0
}
