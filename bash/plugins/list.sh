#! /usr/bin/env bash

function abcli_list() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli list cloud|local <object_name>" \
            "list <object_name>"

        abcli_show_usage "abcli list <path>" \
            "list <path>"
        return
    fi

    local options=$1

    if [ $(abcli_option_int "$options" cloud 0) == 1 ]; then
        local object_name=$(abcli_clarify_object $2 .)

        abcli_eval - \
            aws s3 ls $abcli_s3_object_prefix/$object_name/
        return
    fi

    if [ $(abcli_option_int "$options" local 0) == 1 ]; then
        local object_name=$(abcli_clarify_object $2 .)

        abcli_eval - \
            ls -1lh $abcli_object_root/$object_name
    fi

    abcli_eval - \
        ls -1lh"${@:2}"
}
