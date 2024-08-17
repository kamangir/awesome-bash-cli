#! /usr/bin/env bash

export abcli_path_env_backup=$HOME/env-backup
mkdir -pv $abcli_path_env_backup

function abcli_env() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "@env [keyword]" \
            "show environment variables."

        abcli_env_backup help
        abcli_env_dot "$@"
        return
    fi

    local function_name="abcli_env_$1"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    env | grep "$1" | sort
}

abcli_source_path - \
    caller,suffix=/env

abcli_env_dot_load \
    caller,filename=config.env,suffix=/../..
