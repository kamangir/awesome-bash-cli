#! /usr/bin/env bash

function abcli_open() {
    if [ "$1" == "help" ]; then
        local options="extension=<extension>,${EOPE}filename=<filename>,QGIS"
        abcli_show_usage "@open$ABCUL.$EOP|<object-name>$ABCUL$options" \
            "open <object-name>."
        return
    fi

    local object_name=$(abcli_clarify_object $1 .)

    local options=$2

    local extension=$(abcli_option "$options" extension)
    [[ $(abcli_option_int "$options" QGIS 0) == 1 ]] && extension="qgz"

    local filename=$(abcli_option "$options" filename)
    [[ ! -z "$extension" ]] &&
        filename=$object_name.$extension

    local what=$abcli_object_root/$object_name
    [[ ! -z "$extension" ]] &&
        what=$what/$filename

    abcli_eval - \
        open "$what"

    return 0
}
