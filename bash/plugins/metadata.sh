#! /usr/bin/env bash

function abcli_metadata() {
    local task=${1:-help}

    if [ "$task" == "help" ]; then
        abcli_metadata get "$@"
        abcli_metadata post "$@"
        return
    fi

    if [ "$task" == "get" ]; then
        local options=$2
        if [ $(abcli_option_int "$options" help 0) == 1 ]; then
            local options="${EOP}delim=+,dict.keys,dict.values,${EOPE}key=<key>"
            abcli_show_usage "@metadata get$ABCUL$options,filename$ABCUL<filename.yaml>" \
                "get <filename.yaml>[<key>]"

            abcli_show_usage "@metadata get$ABCUL$options$EOP,filename=<metadata.yaml>,object$ABCUL.|<object-name>$EOPE" \
                "get <object-name>/metadata[<key>]"

            abcli_show_usage "@metadata get$ABCUL$options$EOP,filename=<metadata.yaml>,${EOPE}path$ABCUL<path>" \
                "get <path>/metadata[<key>]"
            return
        fi

        local source_type=$(abcli_option_choice "$options" object,path,filename object)

        local source=$3
        [[ "$source_type" == object ]] &&
            local source=$(abcli_clarify_object $3 .)

        local key=$(abcli_option "$options" key)
        local default=$(abcli_option "$options" default)

        python3 -m abcli.plugins.metadata get \
            --default "$default" \
            --delim $(abcli_option "$options" delim ,) \
            --dict_keys $(abcli_option_int "$options" dict.keys 0) \
            --dict_values $(abcli_option_int "$options" dict.values 0) \
            --filename $(abcli_option "$options" filename metadata.yaml) \
            --key "$key" \
            --source "$source" \
            --source_type $source_type \
            "${@:4}"
        return
    fi

    if [ "$task" == "post" ]; then
        local key=$2
        if [ "$key" == "help" ]; then
            local args="[--verbose 1]"
            abcli_show_usage "@metadata post$ABCUL<key> <value>${ABCUL}filename$ABCUL<filename.yaml>$ABCUL$args" \
                "<filename.yaml>[<key>] = <value>"

            abcli_show_usage "@metadata post$ABCUL<key> <value>$ABCUL${EOP}object,filename=<metadata.yaml>$ABCUL.|<object-name>$EOPE$ABCUL$args" \
                "<object-name>[<key>] = <value>"

            abcli_show_usage "@metadata post$ABCUL<key> <value>${ABCUL}path$EOP,filename=<metadata.yaml>$EOPE$ABCUL<path>$ABCUL$args" \
                "<path>[<key>] = <value>"
            return
        fi

        local options=$4
        local source_type=$(abcli_option_choice "$options" object,path,filename object)

        local source=$5
        [[ "$source_type" == object ]] &&
            local source=$(abcli_clarify_object $5 .)

        python3 -m abcli.plugins.metadata post \
            --filename $(abcli_option "$options" filename metadata.yaml) \
            --key "$key" \
            --value "$3" \
            --source "$source" \
            --source_type $source_type \
            "${@:6}"
        return
    fi

    abcli_log_error "-abcli: metadata: $task: command not found."
    return 1
}
