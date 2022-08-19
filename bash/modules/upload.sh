#! /usr/bin/env bash

function abcli_upload() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name upload [-open,solid]" \
            "upload $ABCLI_OBJECT_NAME [not as open] [and not as solid]."
        return
    fi

    # https://stackoverflow.com/a/45200066
    local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/abcli/$ABCLI_OBJECT_NAME.tar.gz)
    if [ -z "$exists" ]; then
        abcli_log_local "confirmed: $ABCLI_OBJECT_NAME does not exist."
    else
        abcli_log_error "-abcli: upload: $ABCLI_OBJECT_NAME already exists."
        return
    fi

    rm -rf $abcli_object_path/auxiliary

    local options=$1
    local do_open=$(abcli_option_int "$options" "open" 1)
    local do_solid=$(abcli_option_int "$options" "solid" 0)

    if [ "$do_open" == "1" ]; then
        abcli_log "$ABCLI_OBJECT_NAME open upload started."

        aws s3 sync $abcli_object_path/ s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$ABCLI_OBJECT_NAME/

        abcli_tag set $ABCLI_OBJECT_NAME open
    fi

    if [ "$do_solid" == "1" ]; then
        pushd $abcli_object_root > /dev/null

        tar -czvf $ABCLI_OBJECT_NAME.tar.gz ./$ABCLI_OBJECT_NAME

        abcli_log "$ABCLI_OBJECT_NAME solid upload started - $(abcli_file_size $abcli_object_path.tar.gz)"

        aws s3 cp $ABCLI_OBJECT_NAME.tar.gz s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/

        abcli_tag set $ABCLI_OBJECT_NAME solid

        popd > /dev/null
    fi

}