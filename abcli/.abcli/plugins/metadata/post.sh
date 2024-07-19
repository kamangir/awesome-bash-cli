#! /usr/bin/env bash

function abcli_metadata_post() {
    local key=$1

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

    local value=$2

    local options=$3
    local source_type=$(abcli_option_choice "$options" object,path,filename object)

    local source=$4
    [[ "$source_type" == object ]] &&
        source=$(abcli_clarify_object $4 .)

    python3 -m abcli.plugins.metadata post \
        --filename $(abcli_option "$options" filename metadata.yaml) \
        --key "$key" \
        --value "$value" \
        --source "$source" \
        --source_type $source_type \
        "${@:5}"
}
