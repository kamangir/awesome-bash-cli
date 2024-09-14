#! /usr/bin/env bash

function test_abcli_README() {
    local options=$1

    abcli_eval ,$options \
        abcli build_README
}
