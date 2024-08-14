#! /usr/bin/env bash

function abcli_ssm_put() {
    local name=$1

    if [[ "$name" == "help" ]]; then
        local args="[--description <description>]"
        abcli_show_usage "@ssm put <secret-name>$ABCUL<secret-value>$ABCUL$args" \
            "put <secret-name> = <secret-value>"
        return
    fi

    local value=$2

    python3 -m abcli.plugins.ssm \
        put \
        --name "$name" \
        --value "$value" \
        "${@:3}"
}
