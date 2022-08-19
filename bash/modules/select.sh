#! /usr/bin/env bash

function abcli_select() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name select [<object_name>] [~trail]" \
            "select [object_name] [no trail]."
        return
    fi

    local object_name=$(abcli_clarify_object "$1" $(abcli_string_timestamp))

    local options=$2
    local update_trail=$(abcli_option_int "$options" "trail" 1)

    export abcli_object_name_prev=$ABCLI_OBJECT_NAME
    export ABCLI_OBJECT_NAME=$object_name
    
    export abcli_object_path=$abcli_object_root/$ABCLI_OBJECT_NAME
    mkdir -p $abcli_object_path

    cd $abcli_object_path

    if [ "$update_trail" == "1" ] ; then
        abcli_trail $abcli_object_path/$ABCLI_OBJECT_NAME
    fi

    abcli_log "$ABCLI_OBJECT_NAME selected."
}