#! /usr/bin/env bash

function abcli_pypi_browse() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local callable=$([[ "$plugin_name" == "abcli" ]] && echo "@" || echo "$plugin_name ")
        options=""
        [[ "$plugin_name" == abcli ]] && options="${EOP}plugin=<plugin-name>$EOPE"
        abcli_show_usage "${callable}pypi browse $options" \
            "browse pypi/$plugin_name."
        return
    fi

    local module_name=$(abcli_get_module_name_from_plugin $plugin_name)

    abcli_browse "https://pypi.org/project/$module_name/"

    return 0
}
