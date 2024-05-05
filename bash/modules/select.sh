#! /usr/bin/env bash

function abcli_select() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        local options="open,type=<type>,~trail"
        abcli_show_usage "@select [<object-name>]$ABCUL[$options]" \
            "select <object-name>."
        return
    fi

    local object_name=$(abcli_clarify_object "$1" $(abcli_string_timestamp))

    local options=$2
    local update_trail=$(abcli_option_int "$options" trail 1)
    local do_open=$(abcli_option_int "$options" open 0)
    local type_name=$(abcli_option "$options" type object)

    local object_name_var_prev=abcli_${type_name}_name_prev
    export abcli_${type_name}_name_prev2=${!object_name_var_prev}

    local object_name_var=abcli_${type_name}_name
    export abcli_${type_name}_name_prev=${!object_name_var}

    export abcli_${type_name}_name=$object_name

    local object_path=$abcli_object_root/$object_name
    export abcli_${type_name}_path=$object_path
    mkdir -p $object_path

    if [ "$type_name" == object ]; then
        cd $object_path

        [[ "$update_trail" == 1 ]] &&
            abcli_trail $object_path/$object_name
    fi

    abcli_log "📂 $type_name :: $object_name"

    [[ "$do_open" == 1 ]] &&
        open $object_path
}
