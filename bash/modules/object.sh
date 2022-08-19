#! /usr/bin/env bash

function abcli_clarify_object() {
    local object_name=$1
    local default=$2

    if [ -z "$object_name" ] || [ "$object_name" == "-" ] ; then
        local object_name=$default
    fi
    if [ "$object_name" == "." ] ; then
        local object_name=$ABCLI_OBJECT_NAME
    fi
    if [ "$object_name" == ".." ] ; then
        local object_name=$abcli_object_name_prev
    fi
    if [ "$(abcli_keyword_is $object_name validate)" == true ] ; then
        local object_name="validate"
    fi

    echo $object_name
}

function abcli_object() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name object open" \
            "open $ABCLI_OBJECT_NAME."
        return
    fi

    if [ "$task" == "open" ] ; then
        abcli_download

        rm -v ../$ABCLI_OBJECT_NAME.tar.gz
        aws s3 rm "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$ABCLI_OBJECT_NAME.tar.gz"

        abcli_tag set $ABCLI_OBJECT_NAME ~solid

        abcli_upload

        return
    fi

    abcli_log_error "-abcli: object: $task: command not found."
}