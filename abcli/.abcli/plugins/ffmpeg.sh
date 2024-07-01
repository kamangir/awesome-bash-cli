#! /usr/bin/env bash

function abcli_ffmpeg() {
    local task=$(abcli_unpack_keyword $1 help)

    if [[ "$task" == "help" ]]; then
        abcli_ffmpeg_install "$@"
        return
    fi

    local function_name=abcli_ffmpeg_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    abcli_log_error "-@ffmpeg: $task: command not found."
    return 1
}

abcli_source_path - caller,suffix=/ffmpeg
