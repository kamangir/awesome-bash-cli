#! /usr/bin/env bash

function abcli_publish() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli publish$ABCUL<object_name>$ABCUL[random_url]" \
            "publish <object_name> [and randmoize url]."
        abcli_show_usage "abcli publish$ABCUL<object_name>$ABCUL.mp4" \
            "publish every .mp4 in <object_name>."
        abcli_show_usage "abcli publish$ABCUL<object_name>$ABCUL<filename>$ABCUL[<othername>]" \
            "publish <object_name>/<filename> [as <othername>]."
        abcli_show_usage "abcli publish$ABCUL<object_name>${ABCUL}open" \
            "publish every file in <object_name>."
        return
    fi

    local object_name=$(abcli_clarify_object $1 .)

    local filename=$2

    local othername=$3
    if [ -z "$othername" ] ; then
        local othername=$filename
    fi

    if [ -z "$filename" ] || [ "$filename" == "random_url" ] ; then
        abcli_log "publishing $object_name"

        local current_object=$abcli_object_name

        if [ "$filename" == "random_url" ] ; then
            local public_object_name=$(abcli_string_random --length 64)
        else
            local public_object_name=$object_name-published
        fi

        abcli_select $object_name ~trail
        abcli_clone $public_object_name ~meta
        rm *.sh
        rm *.py

        # https://askubuntu.com/a/466225
        find . -type f  ! -name "*.*"  -delete

        abcli_upload ~open,solid

        aws s3 cp \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name.tar.gz \
            s3://$(abcli_aws_s3_public_bucket)/

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$abcli_object_name.tar.gz"
        abcli_log "🔗 $url"

        abcli_select $current_object ~trail

        return
    fi

    if [ "$filename" == "open" ] ; then
        abcli_log "publishing files in $object_name..."

        local current_object=$abcli_object_name

        abcli_select $object_name ~trail
        abcli_clone $object_name-published ~meta
        rm *.sh
        rm *.py

        # https://askubuntu.com/a/466225
        find . -type f  ! -name "*.*"  -delete

        abcli_upload open

        aws s3 sync \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name \
            s3://$(abcli_aws_s3_public_bucket)/$abcli_object_name

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$abcli_object_name"
        abcli_log "🔗 $url"

        abcli_select $current_object ~trail

        return
    fi

    local filename_name=${filename%%.*}
    if [ ! -z "$filename_name" ] ; then
        abcli_log "publishing $object_name/$filename as $othername"

        local public_filename=$(echo $othername | tr / -)
        aws s3 cp \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$object_name/$filename \
            s3://$(abcli_aws_s3_public_bucket)/$object_name-$public_filename

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$object_name-$public_filename"
        abcli_log "🔗 $url"

        return
    fi

    local filename_
    for filename_ in *$filename ; do
        abcli_publish \
            $object_name \
            $filename_ \
            ${@:3}
    done
}