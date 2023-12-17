#! /usr/bin/env bash

function abcli_metadata() {
    local task=${1:-help}

    if [ "$task" == "help" ]; then
        local options="delim=+,dict_keys,dict_values,key=<key>"
        abcli_show_usage "abcli metadata get$ABCUL<filename.yaml>$ABCUL[$options]" \
            "get <filename.yaml>[<key>]"
        abcli_show_usage "abcli metadata get$ABCUL[.|<object-name>]$ABCUL[$options,object,filename=<metadata.yaml>]" \
            "get <object-name>/metadata[<key>]"

        [[ "$2" == "verbose" ]] &&
            python3 -m abcli.plugins.metadata get --help

        return
    fi

    if [ "$task" == "get" ]; then
        local options=$3

        if [ $(abcli_option_int "$options" object 0) == 1 ]; then
            local object_name=$(abcli_clarify_object $2 .)
            local filename=$abcli_object_root/$object_name/$(abcli_option "$options" filename metadata.yaml)
        else
            local filename=$2
        fi

        local key=$(abcli_option "$options" key)
        local default=$(abcli_option "$options" default)
        local delim=$(abcli_option "$options" delim)

        python3 -m abcli.plugins.metadata get \
            --key "$key" \
            --default "$default" \
            --delim "$delim" \
            --dict_keys $(abcli_option_int "$options" dict_keys 0) \
            --dict_values $(abcli_option_int "$options" dict_values 0) \
            --filename $filename \
            "${@:4}"
        return
    fi

    abcli_log_error "-abcli: metadata: $task: command not found."
}
