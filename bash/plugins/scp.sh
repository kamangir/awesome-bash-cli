#! /usr/bin/env bash

function abcli_scp() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli scp ec2|jetson_nano|local|rpi <source-machine> <source> ec2|jetson_nano|local|rpi <destination-machine> <destination> <args>" \
            "scp <source> in <source-machine> to <destination> in <destination-machine>."
        return
    fi

    local source_path=$(abcli_scp_path $1 $2 $3)
    local destination_path=$(abcli_scp_path $4 $5 $6)

    abcli_log "abcli: scp: $source_path -> $destination_path ${@:7}"

    # https://kb.iu.edu/d/agye
    scp ${@:7} $source_path $destination_path
}

function abcli_scp_path() {
    local args=$(abcli_ssh_args $1 $2 ~seed)
    local resource=$3

    if [ -z "$args" ] ; then
        echo $resource
    else
        echo $args:$resource
    fi
}