#! /usr/bin/env bash

function abcli_ssm_get() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "@ssm get <secret-name>" \
            "get <secret-name>"

        abcli_show_usage "@ssm get plugin=<plugin-name>" \
            "get <plugin-name> secrets"

        abcli_show_usage "@ssm get repo=<repo-name>" \
            "get <repo-name> secrets"
        return
    fi

    local secret_name

    local verbose=$(abcli_option_int "$options" verbose 0)
    local plugin_name=$(abcli_option "$options" plugin)
    local repo_name=""
    [[ ! -z "$plugin_name" ]] &&
        repo_name=$(abcli_unpack_repo_name $plugin_name)
    repo_name=$(abcli_option "$options" repo $repo_name)
    if [[ ! -z "$repo_name" ]]; then
        pushd $abcli_path_git/$repo_name >/dev/null
        local line
        local count=0
        for line in $(dotenv \
            --file sample.env \
            list \
            --format shell); do
            [[ $verbose == 1 ]] && abcli_log "$line"

            secret_name=$(python3 -c "print('$line'.split('=',1)[0])")
            abcli_log "🔑 $secret_name"

            secret_value=$(abcli_ssm get $secret_name)

            export $secret_name=$secret_value

            ((count++))
        done
        popd >/dev/null

        abcli_log "🔑 @ssm: get: $repo_name/.env: $count secret(s)"
        return
    fi

    secret_name=$1

    python3 -m abcli.plugins.ssm \
        get \
        --name "$secret_name" \
        "${@:2}"
}
