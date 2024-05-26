#! /usr/bin/env bash

export abcli_publish_prefix=https://$abcli_aws_s3_public_bucket_name.s3.$abcli_aws_region.amazonaws.com

function abcli_publish() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local common_options="as=<public-object-name>,~download"

        options="$EOP$common_options,${EOPE}tar"
        abcli_show_usage "@publish$ABCUL$options$ABCUL$EOP.|<object-name>$EOPE" \
            "publish <object-name>.tar.gz."

        options="$EOP$common_options,prefix=<prefix>,suffix=<.png>"
        abcli_show_usage "@publish$ABCUL$options$ABCUL.|<object-name>$EOPE" \
            "publish <object-name>."

        abcli_log "🔗 $abcli_publish_prefix"
        return
    fi

    local do_download=$(abcli_option_int "$options" download 1)
    local do_tar=$(abcli_option_int "$options" tar 0)
    local prefix=$(abcli_option "$options" prefix)
    local suffix=$(abcli_option "$options" suffix)

    local object_name=$(abcli_clarify_object $2 .)
    [[ "$do_download" == 1 ]] &&
        abcli_download - $object_name

    abcli_tag set $object_name published

    local public_object_name=$(abcli_option "$options" as $object_name)

    if [ "$do_tar" == 1 ]; then
        abcli_log "publishing $object_name -> $public_object_name.tar.gz"

        abcli_upload ~open,solid $object_name
        aws s3 cp \
            $abcli_s3_object_prefix/$object_name.tar.gz \
            s3://$abcli_aws_s3_public_bucket_name/$public_object_name.tar.gz
        abcli_object open $object_name

        abcli_log "🔗 $abcli_publish_prefix/$public_object_name.tar.gz"
        return
    fi

    abcli_log "publishing $object_name -> $public_object_name"
    abcli_log "🔗 $abcli_publish_prefix/$public_object_name/"

    local object_path=$abcli_object_root/$object_name

    if [[ -z "$prefix$suffix" ]]; then
        aws s3 sync \
            $object_path/ \
            s3://$abcli_aws_s3_public_bucket_name/$public_object_name/
        return
    fi

    pushd $object_path >/dev/null
    local filename
    for filename in $(ls *); do
        [[ "$filename" != "$prefix"*"$suffix" ]] && continue

        aws s3 cp \
            $filename \
            s3://$abcli_aws_s3_public_bucket_name/$public_object_name/$filename
    done
    popd >/dev/null
}
