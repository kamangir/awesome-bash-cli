#! /usr/bin/env bash

function abcli_clarify_object() {
    local object_name=$1
    local default=$2
    local type_name=${3:-object}

    local object_var=abcli_${type_name}_name
    local object_var_prev=abcli_${type_name}_name_prev
    local object_var_prev2=abcli_${type_name}_name_prev2

    if [ -z "$object_name" ] || [ "$object_name" == "-" ]; then
        local object_name=$default
    fi
    if [ "$object_name" == "." ]; then
        local object_name=${!object_var}
    fi
    if [ "$object_name" == ".." ]; then
        local object_name=${!object_var_prev}
    fi
    if [ "$object_name" == "..." ]; then
        local object_name=${!object_var_prev2}
    fi
    if [ "$(abcli_keyword_is $object_name validate)" == true ]; then
        local object_name="validate"
    fi

    mkdir -p $abcli_object_root/$object_name

    echo $object_name
}

function abcli_object() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli object open$ABCUL[.|<object-name>]" \
            "open object."
        return
    fi

    if [ "$task" == "open" ]; then
        local object_name=$(abcli_clarify_object $2 .)

        abcli_download object $object_name

        rm -v ../$object_name.tar.gz
        aws s3 rm "$abcli_s3_object_prefix/$object_name.tar.gz"

        abcli_tag set $object_name ~solid

        abcli_upload object $object_name

        return
    fi

    abcli_log_error "-abcli: object: $task: command not found."
}
