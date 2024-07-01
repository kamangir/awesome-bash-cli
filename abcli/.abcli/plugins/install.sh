#! /usr/bin/env bash

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

    abcli_log "installing $filename ..."

    # https://github.com/papertrail/remote_syslog2/releases/tag/v0.21
    local url="https://github.com/papertrail/remote_syslog2/releases/download/v0.21/$filename.tar.gz"

    pushd $abcli_path_temp >/dev/null
    curl -O -L $url
    tar -xzf $filename.tar.gz
    chmod +x remote_syslog/remote_syslog
    popd >/dev/null
}

abcli_install_module papertrail 3.3.1
