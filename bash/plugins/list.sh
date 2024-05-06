#! /usr/bin/env bash

function abcli_list() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "@ls cloud|local <object-name>" \
            "list <object-name>"

        abcli_show_usage "@ls <path>" \
            "list <path>"
        return
    fi

    local on_cloud=$(abcli_option_int "$options" cloud 0)
    local on_local=$(abcli_option_int "$options" local 0)

    [[ "$on_cloud" == 1 ]] ||
        [[ "$on_local" == 1 ]] &&
        local object_name=$(abcli_clarify_object $2 .)

    if [ "$on_cloud" == 1 ]; then
        abcli_eval - \
            aws s3 ls $abcli_s3_object_prefix/$object_name/
    elif [ "$on_local" == 1 ]; then
        abcli_eval - \
            ls -1lh $abcli_object_root/$object_name
    else
        abcli_eval - \
            ls -1 "$@"
    fi

    return 0
}
