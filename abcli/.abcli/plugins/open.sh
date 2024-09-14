#! /usr/bin/env bash

function abcli_open() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="extension=<extension>,filename=<filename>,QGIS"
        abcli_show_usage "@open$ABCUL[$options]$ABCUL[.|<object-name>]" \
            "open <object-name>."
        return
    fi

    local object_name=$(abcli_clarify_object $2 .)

    local extension=$(abcli_option "$options" extension)
    [[ $(abcli_option_int "$options" QGIS 0) == 1 ]] && extension="qgz"

    local filename=$(abcli_option "$options" filename)
    [[ ! -z "$extension" ]] &&
        filename=$object_name.$extension

    local what=$ABCLI_OBJECT_ROOT/$object_name
    [[ ! -z "$extension" ]] &&
        what=$what/$filename

    abcli_log "📜 $what"
    open "$what"
}
