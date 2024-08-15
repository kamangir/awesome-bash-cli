#! /usr/bin/env bash

function abcli_env_dot_load() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="caller,filename=<.env>,plugin=<plugin-name>,suffix=/tests,verbose"
        abcli_show_usage "@env dot load$ABCUL[$options]" \
            "load .env."
        return
    fi

    local use_caller=$(abcli_option_int "$options" caller 0)
    local suffix=$(abcli_option "$options" suffix)
    local path
    if [[ "$use_caller" == 1 ]]; then
        path=$(dirname "$(realpath "${BASH_SOURCE[1]}")")$suffix
    else
        local plugin_name=$(abcli_option "$options" plugin abcli)
        local repo_name=$(abcli_unpack_repo_name $plugin_name)

        path=$abcli_path_git/$repo_name
    fi

    local filename=$(abcli_option "$options" filename .env)
    local verbose=$(abcli_option_int "$options" verbose 0)

    if [[ ! -f "$path/$filename" ]]; then
        abcli_log_warning "$repo_name/$filename: file not found."
        return
    fi

    pushd $path >/dev/null
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

    abcli_log "@env: loaded $count var(s) from $path/$filename"
}
