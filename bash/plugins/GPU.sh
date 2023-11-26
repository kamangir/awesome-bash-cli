#! /usr/bin/env bash

function abcli_gpu() {
    local task=$(abcli_unpack_keyword $1 status)

    if [ "$task" == "help" ]; then
        abcli_gpu_status "$@"
        return
    fi

    local function_name=abcli_gpu_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    abcli_log_error "-abcli: gpu: $task: command not found."
}

function abcli_gpu_status() {
    local task=$(abcli_unpack_keyword $1 show)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli gpu status [show]" \
            "show gpu status."
        abcli_show_usage "abcli gpu status get [~from_cache]" \
            "get gpu status."

        [[ "$(abcli_keyword_is $2 verbose)" == true ]] &&
            python3 -m abcli.plugins.gpu --help

        return
    fi

    if [ $task == "get" ]; then
        local options=$2
        local from_cache=$(abcli_option_int "$options" from_cache 1)

        local status=""
        [[ "$from_cache" == 1 ]] &&
            local status=$abcli_gpu_status

        [[ -z "$status" ]] &&
            local status=$(python3 -m abcli.plugins.gpu \
                status \
                "${@:3}")

        export abcli_gpu_status=$status

        local message=$(python3 -c "print('found. ✅' if $status == 1 else 'not found.')")
        abcli_log "🔋 gpu: $message"
        return
    fi

    if [ $task == "show" ]; then
        abcli_eval - nvidia-smi

        abcli_log "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"

        abcli_gpu_status get
        return
    fi

    abcli_log_error "-abcli: gpu: status: $task: command not found."
}

abcli_gpu_status get
[[ "$abcli_gpu_status" == 1 ]] &&
    export abcli_status_icons="🔋 $abcli_status_icons"
