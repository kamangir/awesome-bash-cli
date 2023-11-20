#! /usr/bin/env bash

function abcli_publish() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="dryrun,extension=<png>,filename=<filename-1+filename-2>,randomize,tar"
        abcli_show_usage "abcli publish$ABCUL[$options]$ABCUL[.|<object_name>]" \
            "publish <object_name>."
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_tar=$(abcli_option "$options" tar 0)
    local do_randomize=$(abcli_option "$options" randomize 0)
    local extension=$(fast_option "$options" extension)
    local filename=$(fast_option "$options" filename)

    local object_name=$(abcli_clarify_object $2 .)

    abcli_tag set $object_name published

    local public_object_name=$object_name
    [[ "$do_randomize" == 1 ]] &&
        local public_object_name=$(abcli_string_random --length 64)

    if [ "$do_tar" ==1 ]; then
        abcli_log "publishing $object_name -> $public_object_name.tar.gz"

        abcli_eval dryrun=$do_dryrun \
            abcli_upload solid $object_name

        abcli_eval dryrun=$do_dryrun \
            aws s3 cp \
            s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$object_name.tar.gz \
            s3://$(abcli_aws_s3_public_bucket)/$public_object_name.tar.gz

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$abcli_object_name.tar.gz"
        abcli_log "🔗 $url"

        return
    fi

    local object_path=
    pushd $object_path >/dev/null
    local filename_
    for filename_ in *; do
        [[ ! -z "$filename" ]] && [[ "+$filename+" != *"+$filename_+"* ]] && continue
        [[ ! -z "$extension" ]] && [[ "$filename_" != *".$extension" ]] && continue

        abcli_eval dryrun=$do_dryrun \
            aws s3 cp \
            $filename_ \
            s3://$(abcli_aws_s3_public_bucket)/$public_object_name/$filename_
    done
    popd >/dev/null
}
