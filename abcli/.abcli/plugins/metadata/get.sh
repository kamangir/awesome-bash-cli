#! /usr/bin/env bash

function abcli_metadata_get() {
    local options=$1

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

    local source=$2
    [[ "$source_type" == object ]] &&
        source=$(abcli_clarify_object $2 .)

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
        "${@:3}"
}
