#! /usr/bin/env bash

function abcli_upload() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "upload [open,-solid]" \
            "upload $abcli_object_name [as open] [and not as solid]."
        return
    fi

    # https://stackoverflow.com/a/45200066
    local exists=$(aws s3 ls kamangir/abcli/$abcli_object_name.tar.gz)
    if [ -z "$exists" ]; then
        abcli_log_local "confirmed: $abcli_object_name does not exist."
    else
        abcli_log_error "$abcli_object_name already exists."
        return
    fi

    local options="$1"
    local do_open=$(abcli_option_int "$options" "open" 0)
    local do_solid=$(abcli_option_int "$options" "solid" 1)

    pushd $abcli_path_storage > /dev/null

    if [ "$do_open" == "1" ]; then
        abcli_log "$abcli_object_name open upload started."

        aws s3 sync $abcli_object_path/ s3://kamangir/abcli/$abcli_object_name/

        abcli_tag set $abcli_object_name open
    fi

    if [ "$do_solid" == "1" ]; then
        tar -czvf $abcli_object_name.tar.gz ./$abcli_object_name

        abcli_log "$abcli_object_name solid upload started - $(abcli_file_size $abcli_object_path.tar.gz)"

        aws s3 cp $abcli_object_name.tar.gz s3://kamangir/abcli/

        abcli_tag set $abcli_object_name solid
    fi

    popd > /dev/null
}