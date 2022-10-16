#! /usr/bin/env bash

function abcli_upload() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli upload$ABCUL[~open,solid]" \
            "upload $abcli_object_name."
        return
    fi

    # https://stackoverflow.com/a/45200066
    local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/abcli/$abcli_object_name.tar.gz)
    if [ -z "$exists" ]; then
        abcli_log_local "confirmed: $abcli_object_name does not exist."
    else
        abcli_log_error "-abcli: upload: $abcli_object_name already exists."
        return
    fi

    rm -rf $abcli_object_path/auxiliary

    local options=$1
    local do_open=$(abcli_option_int "$options" open 1)
    local do_solid=$(abcli_option_int "$options" solid 0)

    if [ "$do_open" == 1 ]; then
        abcli_log "$abcli_object_name open upload started."

        aws s3 sync \
            $abcli_object_path/ \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name/

        abcli_tag set $abcli_object_name open
    fi

    if [ "$do_solid" == 1 ]; then
        pushd $abcli_object_root > /dev/null

        tar -czvf \
            $abcli_object_name.tar.gz \
            ./$abcli_object_name

        abcli_log "$abcli_object_name solid upload started - $(abcli_file_size $abcli_object_path.tar.gz)"

        aws s3 cp \
            $abcli_object_name.tar.gz \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/

        abcli_tag set $abcli_object_name solid

        popd > /dev/null
    fi

}