#! /usr/bin/env bash

function abcli_pypi_install() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="${EOP}dryrun$EOPE"
        abcli_show_usage "@pypi install $options" \
            "install pypi."
        return
    fi

    abcli_log "installing pypi: 🪄"
}
