#! /usr/bin/env bash

function abcli_list() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli list cloud|local <object_name>" \
            "list <object_name>"
        return
    fi

    local options=$1
    local where=$(abcli_option_choice "$options" cloud,local cloud)

    local object_name=$(abcli_clarify_object $2 .)

    if [ "$where" == cloud ]; then
        local s3_uri=$abcli_s3_object_prefix/$object_name/
        abcli_log "🔗 $s3_uri"
        aws s3 ls $s3_uri
    elif [ "$where" == local ]; then
        local path=$abcli_object_root/$object_name
        abcli_log "📂 $path"
        ls $path
    else
        abcli_log_error "-abcli: list: $where: location not found."
        return 1
    fi
}
