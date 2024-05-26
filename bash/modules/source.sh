#! /usr/bin/env bash

function abcli_source_path() {
    local path=$1

    if [[ "$path" == help ]]; then
        abcli_show_usage "abcli_source_path <path> ~log" \
            "source <path>."
        abcli_show_usage "abcli_source_path - caller,~log,suffix=/tests" \
            "source caller path."
        return
    fi

    local options=$2
    local use_caller=$(abcli_option_int "$options" caller 0)
    local do_log=$(abcli_option_int "$options" log 0)
    local suffix=$(abcli_option "$options" suffix)

    [[ "$use_caller" == 1 ]] &&
        path=$(dirname "$(realpath "${BASH_SOURCE[1]}")")

    [[ ! -z "$suffix" ]] &&
        path=$path$suffix

    if [[ ! -d "$path" ]]; then
        abcli_log_error "-abcli: source_path: $path: path not found."
        return 1
    fi

    pushd $path >/dev/null

    local filename
    for filename in *.sh; do
        [[ "$do_log" == 1 ]] &&
            abcli_log "🔹 ${filename%.*}"

        source $filename
    done

    popd >/dev/null
}
