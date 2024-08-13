#! /usr/bin/env bash

function abcli_ssm() {
    local task=$1
    local name=$2

    if [[ "$task" == "help" ]]; then
        abcli_ssm get "$@"
        abcli_ssm put "$@"
        return
    fi

    if [[ "$task" == "get" ]]; then
        if [[ "$name" == "help" ]]; then
            abcli_show_usage "@ssm get <secret-name>" \
                "get <secret-name>"
            return
        fi

        python3 -m abcli.plugins.ssm \
            get \
            --name "$name" \
            "${@:3}"
        return
    fi

    if [[ "$task" == "put" ]]; then
        if [[ "$name" == "help" ]]; then
            local args="[--description <description>]"
            abcli_show_usage "@ssm put <secret-name>$ABCUL<secret-value>$ABCUL$args" \
                "put <secret-name> = <secret-value>"
            return
        fi

        local value=$3

        python3 -m abcli.plugins.ssm \
            put \
            --name "$name" \
            --value "$value" \
            "${@:4}"
        return
    fi

    python3 -m abcli.plugins.ssm "$@"
}
