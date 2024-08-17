#! /usr/bin/env bash

function abcli_ssm_rm() {
    local name=$1

    if [[ "$name" == "help" ]]; then
        abcli_show_usage "@ssm rm <secret-name>" \
            "rm <secret-name>"
        return
    fi

    python3 -m abcli.plugins.ssm \
        rm \
        --name "$name" \
        "${@:2}"
}
