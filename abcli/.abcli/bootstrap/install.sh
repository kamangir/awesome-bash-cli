#! /usr/bin/env bash

function abcli_install_module() {
    [[ "$abcli_is_in_notebook" == true ]] && return

    local module=$1

    local version=${2-"1.1.1"}

    local install_path=$HOME/_abcli_install_checkpoint
    mkdir -pv $install_path

    local install_checkpoint=$install_path/${module}-${version}

    if [ -f "$install_checkpoint" ]; then
        abcli_log "🌀 $module-$version"
    else
        abcli_log "installing $module-$version..."

        eval abcli_install_$module

        touch $install_checkpoint
    fi
}
