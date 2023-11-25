#! /usr/bin/env bash

function abcli_upload() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli upload$ABCUL[~open,solid]$ABCUL[<object-name>]" \
            "upload object."
        abcli_show_usage "abcli upload$ABCUL[filename=<filename>]$ABCUL[<object-name>]" \
            "upload <filename>."
        return
    fi

    local options=$1
    local filename=$(abcli_option "$options" filename)
    local do_open=$(abcli_option_int "$options" open 1)
    local do_solid=$(abcli_option_int "$options" solid 0)

    local object_name=$(abcli_clarify_object $2 .)
    local object_path=$abcli_object_root/$object_name

    # https://stackoverflow.com/a/45200066
    local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$object_name.tar.gz)
    if [ -z "$exists" ]; then
        abcli_log_local "confirmed: $object_name does not exist."
    else
        abcli_log_error "-abcli: upload: $object_name already exists."
        return
    fi

    rm -rf $object_path/auxiliary

    if [ ! -z "$filename" ]; then
        abcli_log "$object_name/$filename upload started - $(abcli_file_size $filename)"

        aws s3 cp \
            $object_path/$filename \
            $abcli_s3_object_prefix/$object_name/

        return
    fi

    if [ "$do_open" == 1 ]; then
        abcli_log "$object_name open upload started."

        aws s3 sync \
            $object_path/ \
            $abcli_s3_object_prefix/$object_name/

        abcli_tag set $object_name open
    fi

    if [ "$do_solid" == 1 ]; then
        pushd $abcli_object_root >/dev/null

        tar -czvf \
            $object_name.tar.gz \
            ./$object_name

        abcli_log "$object_name solid upload started - $(abcli_file_size $object_path.tar.gz)"

        aws s3 cp \
            $object_name.tar.gz \
            $abcli_s3_object_prefix/

        abcli_tag set $object_name solid

        popd >/dev/null
    fi

}
