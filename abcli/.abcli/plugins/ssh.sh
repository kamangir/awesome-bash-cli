#! /usr/bin/env bash

function abcli_add_ssh_keys() {
    if [ -z "$abcli_ssh_keys_added" ] || [ "$1" == "force" ]; then
        eval "$(ssh-agent -s)"

        ssh-add -k $HOME/.ssh/$abcli_git_ssh_key_name

        if [ -f "$HOME/.ssh/abcli" ]; then
            ssh-add -k $HOME/.ssh/abcli
        fi

        export abcli_ssh_keys_added="true"
    fi
}

function abcli_ssh() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli ssh add$ABCUL<filename>" \
            "ssh add <filename>."
        abcli_show_usage "abcli ssh copy_id$ABCUL<filename>${ABCUL}jetson_nano|rpi <machine-name>" \
            "ssh copy-id <filename> to <machine-name>."
        abcli_show_usage "abcli ssh${ABCUL}ec2 <ip-address>$ABCUL[region=<region_1>,user=<ec2-user|ubuntu>,vnc]" \
            "ssh to <ip-address>."
        abcli_show_usage "abcli ssh${ABCUL}jetson_nano|rpi <machine-name>" \
            "ssh to jetson nano|rpi <machine-name>."
        abcli_show_usage "abcli ssh keygen$ABCUL[<filename>]" \
            "keygen <filename>"
        return
    fi

    if [ "$task" == "add" ]; then
        local filename=$(abcli_clarify_input $2 abcli)

        ssh-add -k $HOME/.ssh/$filename
        return
    fi

    # https://www.raspberrypi.com/tutorials/cluster-raspberry-pi-tutorial/
    if [ "$task" == "copy_id" ]; then
        local filename=$(abcli_clarify_input $2 abcli)
        local args=$(abcli_ssh_args ${@:3})

        ssh-copy-id -i $HOME/.ssh/$filename.pub $args
        return
    fi

    # https://www.raspberrypi.com/tutorials/cluster-raspberry-pi-tutorial/
    if [ "$task" == "keygen" ]; then
        local filename=$(abcli_clarify_input $2 abcli)
        ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/$filename
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
    local copy_seed=$(abcli_option_int "$options" seed 1)
    local for_vnc=$(abcli_option_int "$options" vnc 0)

    if [ "$machine_kind" == "ec2" ]; then
        local address=$(echo "$machine_name" | tr . -)
        local region=$(abcli_option "$options" region $abcli_aws_region)
        local url="ec2-$address.$region.compute.amazonaws.com"
        local user=$(abcli_option "$options" user ubuntu)

        ssh-keyscan $url >>~/.ssh/known_hosts

        local address="$user@$url"

        if [ "$copy_seed" == 1 ]; then
            abcli_seed ec2 clipboard,env=worker,~log
        fi

        local pem_filename=$abcli_path_ignore/$abcli_aws_ec2_key_name.pem
        chmod 400 $pem_filename
        if [ "$for_vnc" == 1 ]; then
            echo "-i $pem_filename -L 5901:localhost:5901 $address"
        else
            echo "-i $pem_filename $address"
        fi
        return
    fi

    if [ "$machine_kind" == "jetson_nano" ]; then
        echo abcli@$machine_name.local
        return
    fi

    if [ "$machine_kind" == "local" ]; then
        echo ""
        return
    fi

    if [ "$machine_kind" == "rpi" ]; then
        echo pi@$machine_name.local
        return
    fi

    echo "unknown"
    abcli_log_error "-abcli: abcli_ssh_args: $machine_kind: machine kind not found."
}
