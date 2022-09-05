#! /usr/bin/env bash

function papertrail_install() {
    # https://github.com/papertrail/remote_syslog2/releases/tag/v0.20
    if [[ "$abcli_is_mac" == true ]] ; then
        filename="remote_syslog_darwin_amd64"
    elif [[ "$abcli_is_jetson" == true ]] || [[ "$abcli_is_rpi" == true ]] ; then
        filename="remote_syslog_linux_armhf"
    else
        filename="remote_syslog_linux_amd64"
    fi

    abcli_log_local "decompressing $filename"

    pushd "$abcli_path_abcli/assets/papertrail" > /dev/null
    tar -xvf "$filename.tar.gz"
    popd > /dev/null
}

abcli_install_module papertrail 108