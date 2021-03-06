#! /usr/bin/env bash

export abcli_is_64bit=false
export abcli_is_amazon_linux=false
export abcli_is_ec2=false
export abcli_is_jetson=false
export abcli_is_lite=false
export abcli_is_mac=false
export abcli_is_rpi=false
export abcli_is_ubuntu=false
export abcli_is_vnc=false

if [ "$(uname -m)" == "x86_64" ] ; then
    export abcli_is_64bit=true
fi

if [ -f "$abcli_path_git/lite" ] ; then
    export abcli_is_lite=true
fi

if [ -f "$abcli_path_git/vnc" ] ; then
    export abcli_is_vnc=true
fi

if [[ "$OSTYPE" == "darwin"* ]] ; then
    export abcli_is_mac=true
fi

if [[ "$OSTYPE" == "linux-gnueabihf" ]]; then
    export abcli_is_rpi=true
fi

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
    export abcli_is_ubuntu=true

    if [[ "$abcli_is_64bit" == false ]] ; then
        export abcli_is_jetson=true
        # https://forums.developer.nvidia.com/t/read-serial-number-of-jetson-nano/72955
        export abcli_jetson_nano_serial_number=$(sudo cat /proc/device-tree/serial-number)

        # https://github.com/numpy/numpy/issues/18131#issuecomment-755438271
        # https://github.com/numpy/numpy/issues/18131#issuecomment-756140369
        export OPENBLAS_CORETYPE=ARMV8
    elif [[ "$(sudo dmidecode -s bios-version)" == *"amazon" ]] || [[ "$(sudo dmidecode -s bios-vendor)" == "Amazon"* ]] ; then
        export abcli_is_ec2=true

        if [[ "$USER" == "ec2-user" ]] ; then
            export abcli_is_amazon_linux=true
            # https://unix.stackexchange.com/a/191125
            export abcli_ec2_instance_id=$(ec2-metadata --instance-id | cut -d' ' -f2)
        else
            export abcli_ec2_instance_id=$(ec2metadata --instance-id)
        fi
    else
        # https://stackoverflow.com/a/22991546
        export abcli_ubuntu_computer_id=$(sudo dmidecode | grep -w UUID | sed "s/^.UUID\: //g")
    fi
fi

if [[ "$abcli_is_ec2" == true ]] ; then
    source $abcli_path_home/.bashrc
fi

if [[ "$abcli_is_rpi" == true ]] ; then
    if [[ "$abcli_is_lite" == false ]] ; then
        # https://www.geeks3d.com/hacklab/20160108/how-to-disable-the-blank-screen-on-raspberry-pi-raspbian/
        sudo xset s off
        sudo xset -dpms
        sudo xset s noblank

        # wait for internet connection to establish
        sleep 5
    fi
fi

if [[ "$abcli_is_ec2" == true ]] ; then
    conda activate amazonei_tensorflow2_p36
else
    conda activate abcli
fi