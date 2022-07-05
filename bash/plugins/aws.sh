#! /usr/bin/env bash

function abcli_aws_json_get() {
    python3 -m abcli.plugins.aws \
        get_from_json \
        --thing "$1" \
        ${@:2}
}

function abcli_aws_region() {
    abcli_aws_json_get "['region']"
}