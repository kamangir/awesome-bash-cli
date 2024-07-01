#! /usr/bin/env bash

function abcli_ffmpeg_install() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "@ffmpeg install" \
            "install ffmpeg."
        return
    fi

    if [[ "$abcli_is_ec2" == true ]]; then
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

        return
    fi

    if [[ "$abcli_is_mac" == true ]]; then
        brew install ffmpeg
        return
    fi

    abcli_log_error "-@ffmpeg: install: instructions not found."
    return 1
}
