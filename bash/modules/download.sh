#! /usr/bin/env bash

function abcli_download() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name download" \
            "download $ABCLI_OBJECT_NAME."
        abcli_help_line "$abcli_cli_name download <filename>" \
            "download $ABCLI_OBJECT_NAME/filename."
        abcli_help_line "$abcli_cli_name download object <object_name>" \
            "download object_name."
        abcli_help_line "$abcli_cli_name download object <object_name> <filename>" \
            "download object_name/filename."
        return
    fi

    if [ "$task" == "object" ] ; then
        local object_name=$2

        local abcli_object_name_current=$ABCLI_OBJECT_NAME

        abcli_select $object_name ~trail

        abcli_download ${@:3}

        abcli_select $abcli_object_name_current ~trail

        return
    fi

    if [ -f "../$ABCLI_OBJECT_NAME.tar.gz" ] ; then
        echo "$ABCLI_OBJECT_NAME already exists - skipping download."
        return
    fi

    local filename=$1
    if [ ! -z "$filename" ] ; then
        abcli_log "$ABCLI_OBJECT_NAME/$filename download started."
        aws s3 cp "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$ABCLI_OBJECT_NAME/$filename" "$abcli_object_path/$filename"
    else
        local exists=$(aws s3 ls $(abcli_aws_s3_bucket)/abcli/$ABCLI_OBJECT_NAME.tar.gz)
        if [ -z "$exists" ] ; then
            abcli_log "$ABCLI_OBJECT_NAME open download started."

            aws s3 sync "s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$ABCLI_OBJECT_NAME" .
        else
            abcli_log "$ABCLI_OBJECT_NAME solid download started."

            pushd .. > /dev/null

            aws s3 cp "s3://$(abcli_aws_s3_bucket)/abcli/$ABCLI_OBJECT_NAME.tar.gz" .

            abcli_log "$ABCLI_OBJECT_NAME download completed - $(abcli_file_size $ABCLI_OBJECT_NAME.tar.gz)"

            tar -xvf "$ABCLI_OBJECT_NAME.tar.gz"

            popd > /dev/null
        fi
    fi

    abcli_log "$ABCLI_OBJECT_NAME download completed."
}
