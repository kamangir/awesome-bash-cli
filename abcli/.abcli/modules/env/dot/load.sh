#! /usr/bin/env bash

function abcli_env_dot_load() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="filename=<.env>,plugin=<plugin-name>,verbose"
        abcli_show_usage "@env dot load$ABCUL[$options]" \
            "load .env."
        return
    fi

    local plugin_name=$(abcli_option "$options" plugin abcli)
    local repo_name=$(abcli_unpack_repo_name $plugin_name)

    local filename=$(abcli_option "$options" filename .env)
    local verbose=$(abcli_option_int "$options" verbose 0)

    if [[ ! -f "$abcli_path_git/$repo_name/$filename" ]]; then
        abcli_log_warning "$repo_name/$filename: file not found."
        return
    fi

    pushd $abcli_path_git/$repo_name >/dev/null
    local line
    local count=0
    for line in $(dotenv \
        --file $filename \
        list \
        --format shell); do
        [[ $verbose == 1 ]] && abcli_log "$line"

        export "$line"
        ((count++))
    done
    popd >/dev/null

    abcli_log "📜 @env: $repo_name: $filename: $count var(s)"
}
