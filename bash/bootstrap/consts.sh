#! /usr/bin/env bash

export abc_path_abc=$(python3 -c "import os;print(os.sep.join('$abc_path_bash'.split(os.sep)[:-1]))")
export abc_path_git=$(python3 -c "import os;print(os.sep.join('$abc_path_abc'.split(os.sep)[:-1]))")
export abc_path_home=$(python3 -c "import os;print(os.sep.join('$abc_path_git'.split(os.sep)[:-1]))")
export abc_path_scratch="$abc_path_home/scratch"
export abc_asset_root_folder="$abc_path_scratch/abc"
export abc_path_static="$abc_path_abc/hmi/static"

mkdir -p $abc_path_scratch

export abc_is_64bit=false
export abc_is_amazon_linux=false
export abc_is_ec2=false
export abc_is_jetson=false
export abc_is_lite=false
export abc_is_mac=false
export abc_is_rpi=false
export abc_is_ubuntu=false
export abc_is_vnc=false

if [ "$(uname -m)" == "x86_64" ] ; then
    export abc_is_64bit=true
fi

if [ -f "$abc_path_git/lite" ] ; then
    export abc_is_lite=true
fi

if [ -f "$abc_path_git/vnc" ] ; then
    export abc_is_vnc=true
fi

if [[ "$OSTYPE" == "darwin"* ]] ; then
    export abc_is_mac=true
fi

if [[ "$OSTYPE" == "linux-gnueabihf" ]]; then
    export abc_is_rpi=true
fi

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
    export abc_is_ubuntu=true

    if [[ "$abc_is_64bit" == false ]] ; then
        export abc_is_jetson=true
        # https://forums.developer.nvidia.com/t/read-serial-number-of-jetson-nano/72955
        export abc_jetson_nano_serial_number=$(sudo cat /proc/device-tree/serial-number)

        # https://github.com/numpy/numpy/issues/18131#issuecomment-755438271
        # https://github.com/numpy/numpy/issues/18131#issuecomment-756140369
        export OPENBLAS_CORETYPE=ARMV8
    elif [[ "$(sudo dmidecode -s bios-version)" == *"amazon" ]] || [[ "$(sudo dmidecode -s bios-vendor)" == "Amazon"* ]] ; then
        export abc_is_ec2=true

        if [[ "$USER" == "ec2-user" ]] ; then
            export abc_is_amazon_linux=true
            # https://unix.stackexchange.com/a/191125
            export abc_ec2_instance_id=$(ec2-metadata --instance-id | cut -d' ' -f2)
        else
            export abc_ec2_instance_id=$(ec2metadata --instance-id)
        fi
    else
        # https://stackoverflow.com/a/22991546
        export abc_ubuntu_computer_id=$(sudo dmidecode | grep -w UUID | sed "s/^.UUID\: //g")
    fi
fi

export abc_wifi_ssid=""

if [[ "$abc_is_jetson" == true ]] ; then
    # https://code.luasoftware.com/tutorials/jetson-nano/jetson-nano-connect-to-wifi-via-command-line/
    abc_wifi_ssid=$(iwgetid)
    export abc_wifi_ssid=$(python3 -c "print('$abc_wifi_ssid'.split('\"')[1])")
fi