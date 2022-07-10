#! /usr/bin/env bash

function abcli_publish() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name publish object_1 [random_url]" \
            "publish object_1 [and randmoize public url]."
        abcli_help_line "$abcli_cli_name publish object_1 .mp4" \
            "publish every .mp4 in object_1."
        abcli_help_line "$abcli_cli_name publish object_1 filename_1 [othername]" \
            "publish object_1/filename_1 [as othername]."
        abcli_help_line "$abcli_cli_name publish object_1 open" \
            "publish every file in object_1."
        return
    fi

    local object_name=$(abcli_clarify_object "$1" $abcli_object_name)

    local filename=$2

    local othername=$3
    if [ -z "$othername" ] ; then
        local othername=$filename
    fi

    if [ -z "$filename" ] || [ "$filename" == "random_url" ] ; then
        abcli_log "publishing $object_name"

        local abcli_object_name_current=$abcli_object_name

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

        abcli_upload solid

        aws s3 cp s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name.tar.gz s3://$(abcli_aws_s3_public_bucket)/

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$abcli_object_name.tar.gz"
        abcli_log "published $object_name as $url"

        abcli_select $abcli_object_name_current
    elif [ "$filename" == "open" ] ; then
        abcli_log "publishing files in $object_name..."

        local abcli_object_name_current=$abcli_object_name

        abcli_select $object_name ~trail
        abcli_clone $object_name-published ~meta
        rm *.sh
        rm *.py

        # https://askubuntu.com/a/466225
        find . -type f  ! -name "*.*"  -delete

        abcli_upload open

        aws s3 sync s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$abcli_object_name s3://$(abcli_aws_s3_public_bucket)/$abcli_object_name

        local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/$abcli_object_name"
        abcli_log "published $object_name as $url"

        abcli_select $abcli_object_name_current
    else
        local filename_name=${filename%%.*}
        if [ ! -z "$filename_name" ] ; then
            abcli_log "publishing $object_name/$filename as $othername"

            abcli_upload open

            local public_filename=$(echo $othername | tr / -)
            aws s3 cp s3://$(abcli_aws_s3_bucket)/$(abcli_aws_s3_prefix)/$object_name/$filename s3://$(abcli_aws_s3_public_bucket)/${object_name}-${public_filename}

            local url="https://$(abcli_aws_s3_public_bucket).s3.$(abcli_aws_region).amazonaws.com/${object_name}-${public_filename}"
            abcli_log "published $object_name/$filename as $url"
        else
            local list_of_files=(`ls *$filename`)
            local list_of_files=${list_of_files[*]}
            local list_of_files=$(python3 -c "print(' '.join([thing for thing in '$list_of_files'.split(' ') if thing.endswith('$filename')]))")
            abcli_log "$(abcli_list_len $list_of_files space) file(s) found: $list_of_files"

            for filename_ in $list_of_files ; do
                abcli_publish $object_name $filename_ ${@:3}
            done

            return
        fi
    fi
}