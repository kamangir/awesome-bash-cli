#! /usr/bin/env bash

function abcli_install_ffmpeg() {
    if  [ "$bolt_is_ec2" == true ] ; then
        # https://maskaravivek.medium.com/how-to-install-ffmpeg-on-ec2-running-amazon-linux-451e4a8e2694
        pushd /usr/local/bin > /dev/null
        sudo mkdir ffmpeg
        cd ffmpeg
        sudo wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
        sudo tar -xf ffmpeg-release-amd64-static.tar.xz
        cd ffmpeg-*
        sudo cp -a ./ ../
        sudo ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg
        popd > /dev/null
        ffmpeg -version
    fi
}

abcli_install_module ffmpeg 101