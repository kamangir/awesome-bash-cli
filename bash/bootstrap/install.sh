#! /usr/bin/env bash

function abcli_install_module() {
    [[ "$abcli_is_in_notebook" == true ]] && return

    local module=$1
    local version=${2-101}

    if [ -f "$abcli_path_git/abcli_install_${module}_${version}_complete" ]; then
        abcli_log "✅ $module-$version"
    else
        abcli_log "installing $module-$version..."

        eval abcli_install_$module

        touch $abcli_path_git/abcli_install_${module}_${version}_complete
    fi
}
