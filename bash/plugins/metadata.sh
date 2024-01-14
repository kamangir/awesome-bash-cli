#! /usr/bin/env bash

function abcli_metadata() {
    local task=${1:-help}

    if [ "$task" == "help" ]; then
        abcli_metadata get "$@"
        abcli_metadata update "$@"
        return
    fi

    if [ "$task" == "get" ]; then
        local options=$2
        if [ $(abcli_option_int "$options" help 0) == 1 ]; then
            local options="${EOP}delim=+,dict_keys,dict_values,${EOPE}key=<key>"
            abcli_show_usage "abcli metadata get$ABCUL$options,filename$ABCUL<filename.yaml>" \
                "get <filename.yaml>[<key>]"

            abcli_show_usage "abcli metadata get$ABCUL$options$EOP,filename=<metadata.yaml>,object_name$ABCUL.|<object-name>$EOPE" \
                "get <object-name>/metadata[<key>]"

            abcli_show_usage "abcli metadata get$ABCUL$options$EOP,filename=<metadata.yaml>,${EOPE}object_path$ABCUL<object-path>" \
                "get <object-path>/metadata[<key>]"
            return
        fi

        local source_type=$(abcli_option_choice "$options" object_name,object_path,filename object_name)

        local source=$3
        [[ "$source_type" == object_name ]] &&
            local source=$(abcli_clarify_object $3 .)

        local key=$(abcli_option "$options" key)
        local default=$(abcli_option "$options" default)

        python3 -m abcli.plugins.metadata get \
            --default "$default" \
            --delim $(abcli_option "$options" delim ,) \
            --dict_keys $(abcli_option_int "$options" dict_keys 0) \
            --dict_values $(abcli_option_int "$options" dict_values 0) \
            --filename $(abcli_option "$options" filename metadata.yaml) \
            --key "$key" \
            --source "$source" \
            --source_type $source_type \
            "${@:4}"
        return
    fi

    if [ "$task" == "update" ]; then
        local key=$2
        if [ "$key" == "help" ]; then
            abcli_show_usage "abcli metadata update$ABCUL<key> <value>${ABCUL}filename$ABCUL<filename.yaml>" \
                "<filename.yaml>[<key>] = <value>"

            abcli_show_usage "abcli metadata update$ABCUL<key> <value>$ABCUL${EOP}object_name,filename=<metadata.yaml>$ABCUL.|<object-name>$EOPE" \
                "<object-name>[<key>] = <value>"

            abcli_show_usage "abcli metadata update$ABCUL<key> <value>${ABCUL}object_path$EOP,filename=<metadata.yaml>$EOPE$ABCUL<object-path>" \
                "<object-path>[<key>] = <value>"
            return
        fi

        local options=$4
        local source_type=$(abcli_option_choice "$options" object_name,object_path,filename object_name)

        local source=$5
        [[ "$source_type" == object_name ]] &&
            local source=$(abcli_clarify_object $5 .)

        python3 -m abcli.plugins.metadata update \
            --filename $(abcli_option "$options" filename metadata.yaml) \
            --key "$key" \
            --value "$3" \
            --source "$source" \
            --source_type $source_type \
            "${@:6}"
        return
    fi

    abcli_log_error "-abcli: metadata: $task: command not found."
}
