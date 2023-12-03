#! /usr/bin/env bash

export abcli_publish_prefix=https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com

function abcli_publish() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="~download,extension=<png>,filename=<filename-1+filename-2>,randomize,tar"
        abcli_show_usage "abcli publish$ABCUL[$options]$ABCUL[.|<object_name>]" \
            "publish <object_name>."

        abcli_log "🔗 $abcli_publish_prefix"
        return
    fi

    local do_download=$(abcli_option_int "$options" download 1)
    local do_tar=$(abcli_option_int "$options" tar 0)
    local do_randomize=$(abcli_option_int "$options" randomize 0)
    local extension=$(abcli_option "$options" extension)
    local filename=$(abcli_option "$options" filename)

    local object_name=$(abcli_clarify_object $2 .)
    [[ "$do_download" == 1 ]] &&
        abcli_download object $object_name

    abcli_tag set $object_name published

    local public_object_name=$object_name
    [[ "$do_randomize" == 1 ]] &&
        local public_object_name=$(abcli_string_random --length 64)

    if [ "$do_tar" == 1 ]; then
        abcli_log "publishing $object_name -> $public_object_name.tar.gz"

        abcli_upload ~open,solid $object_name
        aws s3 cp \
            $abcli_s3_object_prefix/$object_name.tar.gz \
            s3://$(abcli_aws_s3_public_bucket)/$public_object_name.tar.gz
        abcli_object open $object_name

        abcli_log "🔗 $abcli_publish_prefix/$public_object_name.tar.gz"
        return
    fi

    abcli_log "publishing $object_name -> $public_object_name"
    abcli_log "🔗 $abcli_publish_prefix/$public_object_name/"

    local object_path=$abcli_object_root/$object_name

    if [[ -z "$extension$filename" ]]; then
        aws s3 sync \
            $object_path/ \
            s3://$(abcli_aws_s3_public_bucket)/$public_object_name/
        return
    fi

    pushd $object_path >/dev/null
    local filename_
    for filename_ in $(ls *); do
        [[ ! -z "$filename" ]] && [[ "+$filename+" != *"+$filename_+"* ]] && continue
        [[ ! -z "$extension" ]] && [[ "$filename_" != *".$extension" ]] && continue

        aws s3 cp \
            $filename_ \
            s3://$(abcli_aws_s3_public_bucket)/$public_object_name/$filename_
    done
    popd >/dev/null
}
