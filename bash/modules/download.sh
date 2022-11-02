#! /usr/bin/env bash

function abcli_download() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
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

    if [ "$task" == "object" ] ; then
        local object_name=$2

        local current_object=$abcli_object_name

        abcli_select $object_name ~trail

        abcli_download ${@:3}

        abcli_select $current_object ~trail

        return
    fi

    if [ -f "../$abcli_object_name.tar.gz" ] ; then
        echo "$abcli_object_name already exists - skipping download."
        return
    fi

    local filename=$1
    if [ ! -z "$filename" ] ; then
        abcli_log "$abcli_object_name/$filename download started."
        aws s3 cp "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name/$filename" "$abcli_object_path/$filename"
    else
        local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/abcli/$abcli_object_name.tar.gz)
        if [ -z "$exists" ] ; then
            abcli_log "$abcli_object_name open download started."

            aws s3 sync "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name" .
        else
            abcli_log "$abcli_object_name solid download started."

            pushd .. > /dev/null

            aws s3 cp "s3://$(abcli_aws_s3_bucket)/abcli/$abcli_object_name.tar.gz" .

            abcli_log "$abcli_object_name download completed - $(abcli_file_size $abcli_object_name.tar.gz)"

            tar -xvf "$abcli_object_name.tar.gz"

            popd > /dev/null
        fi
    fi

    abcli_log "$abcli_object_name download completed."
}
