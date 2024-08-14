#! /usr/bin/env bash

function abcli_ssm_get() {
    local name=$1

    if [[ "$name" == "help" ]]; then
        abcli_show_usage "@ssm get <secret-name>" \
            "get <secret-name>"
        return
    fi

    python3 -m abcli.plugins.ssm \
        get \
        --name "$name" \
        "${@:2}"
}
