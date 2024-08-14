#! /usr/bin/env bash

function abcli_env_dot() {
    local task=${1:-cat}
    [[ "$task" == "copy" ]] && task="cp"

    if [[ "$task" == "help" ]]; then
        abcli_env_dot_cat "$@"
        abcli_env_dot_cp "$@"
        abcli_env_dot_edit "$@"

        abcli_show_usage "@env dot get <variable>" \
            "<variable>."
        abcli_show_usage "@env dot list" \
            "list env repo."

        abcli_env_dot_load "$@"

        abcli_show_usage "@env dot set <variable> <value>" \
            "<variable> = <value>."
        return
    fi

    local function_name="abcli_env_dot_$1"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    if [ "$task" == "get" ]; then
        pushd $abcli_path_abcli >/dev/null
        dotenv get "${@:2}"
        popd >/dev/null
        return
    fi

    if [[ "$task" == "list" ]]; then
        ls -1lh $abcli_path_assets/env/*.env
        return
    fi

    if [ "$task" == "set" ]; then
        pushd $abcli_path_abcli >/dev/null
        dotenv set "${@:2}"
        popd >/dev/null
        return
    fi

    abcli_log_error "-@env: $task: command not found."
    return 1
}

abcli_source_path - caller,suffix=/dot
