#! /usr/bin/env bash

function abcli_select() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli select [object_1] [~trail]" \
            "select [object_1] [no trail]."
        return
    fi

    local object_name=$(abcli_clarify_object "$1" $(abcli_string_timestamp))

    local options="$2"
    local update_trail=$(abcli_option_int "$options" "trail" 1)

    export abcli_object_name_prev=$abcli_object_name
    export abcli_object_name=$object_name
    
    export abcli_object_path=$abcli_object_root/$abcli_object_name
    mkdir -p $abcli_object_path

    cd $abcli_object_path

    if [ "$update_trail" == "1" ] ; then
        abcli_trail $abcli_object_path/$abcli_object_name
    fi

    abcli_log "$abcli_object_name selected."
}