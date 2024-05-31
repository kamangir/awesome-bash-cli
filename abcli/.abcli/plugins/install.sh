#! /usr/bin/env bash

function abcli_install_ffmpeg() {
    # https://maskaravivek.medium.com/how-to-install-ffmpeg-on-ec2-running-amazon-linux-451e4a8e2694
    pushd /usr/local/bin >/dev/null
    sudo mkdir ffmpeg
    cd ffmpeg
    sudo wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
    sudo tar -xf ffmpeg-release-amd64-static.tar.xz
    cd ffmpeg-*
    sudo cp -a ./ ../
    sudo ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg
    popd >/dev/null
    ffmpeg -version
}

function abcli_install_papertrail() {
    local filename
    # https://github.com/papertrail/remote_syslog2/releases/tag/v0.20
    if [[ "$abcli_is_mac" == true ]]; then
        filename="remote_syslog_darwin_amd64"
    elif [[ "$abcli_is_jetson" == true ]] || [[ "$abcli_is_rpi" == true ]]; then
        filename="remote_syslog_linux_armhf"
    else
        filename="remote_syslog_linux_amd64"
    fi

    local path=$abcli_path_temp/remote_syslog2
    mkdir -pv $path

    # https://github.com/papertrail/remote_syslog2/releases/tag/v0.20
    local url="https://github.com/papertrail/remote_syslog2/releases/download/v0.20/$filename.tar.gz"

    curl -L $url | tar -xz -C $path
}

[[ "$abcli_is_ec2" == true ]] &&
    abcli_install_module ffmpeg 2.1.1

abcli_install_module papertrail 3.1.1
