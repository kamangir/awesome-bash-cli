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

        abcli_show_usage "@env memory" \
            "show memory status."
        return
    fi

    local function_name="abcli_env_$1"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    if [ "$task" == memory ]; then
        grep MemTotal /proc/meminfo
        return
    fi

    abcli_eval - \
        "env | grep abcli_ | grep \"$1\" | sort"
}

abcli_source_path - caller,suffix=/env

abcli_env dot load
abcli_env dot load \
    filename=abcli/config.env
