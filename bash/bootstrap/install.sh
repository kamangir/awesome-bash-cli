#! /usr/bin/env bash

function abcli_install_module() {
    local module=$1
    local version=${2-101}

    if [ -f "$abcli_path_git/abcli_install_${module}_${version}_complete" ] ; then
        abcli_log "✅  $module-$version"
    else
        abcli_log "installing $module-$version..."

        eval ${module}_install

        touch $abcli_path_git/abcli_install_${module}_${version}_complete
    fi
}