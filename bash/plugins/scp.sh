#! /usr/bin/env bash

function abcli_scp() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli scp ec2|jetson_nano|local|rpi <source-machine> ec2|jetson_nano|local|rpi <destination-machine> <args> <source> <destination>" \
            "scp <source> in <source-machine> to <destination> in <destination-machine>."
        return
    fi

    local machine_kind=$(abcli_clarify_arg $1)
    local machine_name=$2
    local source=$3
    local destination="$4"

    if [ "$machine_kind" == "copy" ] ; then
        local ip_address=$(echo "$address" | tr . -)
        local region=$(abcli_option "$options" "region" $(abcli_aws_region))
        local url="ec2-$ip_address.$region.compute.amazonaws.com"

        scp-keyscan $url >> ~/.scp/known_hosts

        local user=$(abcli_option "$options" user ubuntu)
        local url="$user@$url"

        abcli_log "scp to $url started: $intent"

        abcli_seed output=clipboard,target=ec2,update

        local key_name=$(abcli_aws_json_get "['ec2']['key_name']")
        local pem_filename=$abcli_path_bash/bootstrap/config/$key_name.pem
        chmod 400 $pem_filename
        if [[ "$intent" == "vnc" ]] ; then
            scp -i $pem_filename -L 5901:localhost:5901 $url
        else
            scp -i $pem_filename $url
        fi
    elif [ "$machine_kind" == "jetson_nano" ] ; then
        scp abcli@$address.local
    elif [ "$machine_kind" == "rpi" ] ; then
        scp pi@$address.local
    else
        abcli_log_error "-abcli: scp: $machine_kind: machine kind not found."
    fi
}