#! /usr/bin/env bash

function abcli_pypi_build() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="${EOP}dryrun,install,${EOPE}publish"
        [[ "$plugin_name" == abcli ]] && options="$options$EOP,plugin=<plugin-name>$EOPE"
        abcli_show_usage "@pypi build$ABCUL$options" \
            "build $plugin_name for pypi."
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_install=$(abcli_option_int "$options" install 0)
    local do_publish=$(abcli_option_int "$options" publish 0)

    [[ "$do_install" == 1 ]] &&
        abcli_pypi_install $options

    abcli_log "pypi: building $plugin_name..."

    echo "🪄"
}
