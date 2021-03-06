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
        abcli_help_line "$abcli_cli_name ssh ec2/jetson_nano/rpi 1-2-3-4 [./vnc/worker/worker,gpu] [region=region_1,user=ec2-user/ubuntu]" \
            "ssh to 1-2-3-4 [on region_1] [for vnc/worker/worker,gpu] [as user]."
        return
    fi

    local kind=$1
    local address="$2"
    local intent="$3"

    local options=$4

    if [ -z "$address" ] ; then
        abcli_log_error "-abcli: ssh: address missing."
        return
    fi

    if [ "$kind" == "ec2" ] ; then
        local ip_address=$(echo "$address" | tr . -)
        local region=$(abcli_option "$options" "region" $(abcli_aws_region))
        local url="ec2-$ip_address.$region.compute.amazonaws.com"

        ssh-keyscan $url >> ~/.ssh/known_hosts

        local user=$(abcli_option "$options" user ubuntu)
        local url="$user@$url"

        abcli_log "ssh to $url started: $intent"

        abcli_seed output=clipboard,target=ec2,update

        local key_name=$(abcli_aws_json_get "['ec2']['key_name']")
        local pem_filename=$abcli_path_bash/bootstrap/config/$key_name.pem
        chmod 400 $pem_filename
        if [[ "$intent" == "vnc" ]] ; then
            ssh -i $pem_filename -L 5901:localhost:5901 $url
        else
            ssh -i $pem_filename $url
        fi
    elif [ "$kind" == "jetson_nano" ] ; then
        ssh abcli@$address.local
    elif [ "$kind" == "rpi" ] ; then
        ssh pi@$address.local
    else
        abcli_log_error "-abcli: ssh: $kind: kind not found."
    fi
}