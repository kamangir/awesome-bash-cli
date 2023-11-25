#! /usr/bin/env bash

function abcli_download() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli download" \
            "download $abcli_object_name."
        abcli_show_usage "abcli download <filename>" \
            "download $abcli_object_name/<filename>."
        abcli_show_usage "abcli download object <object_name>" \
            "download <object_name>."
        abcli_show_usage "abcli download object <object_name> <filename>" \
            "download <object_name>/<filename>."
        return
    fi

    local object_name=$abcli_object_name
    local filename=$1
    if [ "$task" == "object" ]; then
        local object_name=$(abcli_clarify_object $2 .)
        local filename=$3
    fi
    local object_path=$abcli_object_root/$object_name

    if [ -f "../$object_name.tar.gz" ]; then
        echo "$object_name already exists - skipping download."
        return 1
    fi

    if [ ! -z "$filename" ]; then
        abcli_log "$object_name/$filename download started."
        aws s3 cp "$abcli_s3_object_prefix/$object_name/$filename" "$object_path/$filename"
    else
        local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$object_name.tar.gz)
        if [ -z "$exists" ]; then
            abcli_log "$object_name open download started."

            aws s3 sync "$abcli_s3_object_prefix/$object_name" "$object_path"
        else
            abcli_log "$object_name solid download started."

            pushd $abcli_object_root >/dev/null

            aws s3 cp "$abcli_s3_object_prefix/$object_name.tar.gz" .

            abcli_log "$object_name download completed - $(abcli_file_size $object_name.tar.gz)"

            tar -xvf "$object_name.tar.gz"

            popd >/dev/null
        fi
    fi

    abcli_log "$object_name download completed."
}
