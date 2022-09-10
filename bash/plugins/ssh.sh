#! /usr/bin/env bash

function abcli_add_ssh_keys() {
    if [ -z "$abcli_ssh_keys_added" ] || [ "$1" == "force" ] ; then
        eval "$(ssh-agent -s)"
        ssh-add -k $abcli_path_home/.ssh/$abcli_git_ssh_key_name

        export abcli_ssh_keys_added="true"
    fi
}

function abcli_ssh() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli ssh ec2 <1-2-3-4> [region=<region_1>,user=<ec2-user|ubuntu>,vnc]" \
            "ssh to <1-2-3-4> [on <region_1>] [as user] [and start vnc]."
        abcli_help_line "abcli ssh jetson_nano|rpi <machine-name>" \
            "ssh to jetson nano|rpi <machine-name>."
        return
    fi

    local args=$(abcli_ssh_args $@)
    abcli_log "abcli: ssh: $args"
    ssh $args
}

function abcli_ssh_args() {
    local machine_kind=$(abcli_clarify_input $1 local)
    local machine_name=$2
    local options=$3
    local copy_seed=$(abcli_option_int "$options" "seed" 1)
    local for_vnc=$(abcli_option_int "$options" "vnc" 0)

    if [ "$machine_kind" == "ec2" ] ; then
        local address=$(echo "$machine_name" | tr . -)
        local region=$(abcli_option "$options" "region" $(abcli_aws_region))
        local url="ec2-$address.$region.compute.amazonaws.com"
        local user=$(abcli_option "$options" user ubuntu)

        ssh-keyscan $url >> ~/.ssh/known_hosts

        local address="$user@$url"

        if [ "$copy_seed" == 1 ] ; then
            abcli_seed ~log,output=clipboard,target=ec2,update
        fi

        local key_name=$(abcli_aws_json_get "['ec2']['key_name']")
        local pem_filename=$abcli_path_bash/bootstrap/config/$key_name.pem
        chmod 400 $pem_filename
        if [ "$for_vnc" == 1 ] ; then
            echo "-i $pem_filename -L 5901:localhost:5901 $address"
        else
            echo "-i $pem_filename $address"
        fi
        return
    fi

    if [ "$machine_kind" == "jetson_nano" ] ; then
        echo abcli@$machine_name.local
        return
    fi

    if [ "$machine_kind" == "local" ] ; then
        echo ""
        return
    fi

    if [ "$machine_kind" == "rpi" ] ; then
        echo pi@$machine_name.local
        return
    fi

    echo "unknown"
    abcli_log_error "-abcli: abcli_ssh_args: $machine_kind: machine kind not found."
}