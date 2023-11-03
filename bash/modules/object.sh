#! /usr/bin/env bash

function abcli_clarify_object() {
    local object_name=$1
    local default=$2
    local plugin_name=${3:-abcli}

    local object_var=${plugin_name}_object_name
    local object_var_prev=${plugin_name}_object_name_prev
    local object_var_prev2=${plugin_name}_object_name_prev2

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
        abcli_show_usage "abcli object open" \
            "open $abcli_object_name."
        return
    fi

    if [ "$task" == "open" ]; then
        abcli_download

        rm -v ../$abcli_object_name.tar.gz
        aws s3 rm "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name.tar.gz"

        abcli_tag set $abcli_object_name ~solid

        abcli_upload

        return
    fi

    abcli_log_error "-abcli: object: $task: command not found."
}
