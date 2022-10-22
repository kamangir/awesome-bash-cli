#! /usr/bin/env bash

function abcli_source_path() {
    local path=$1

    local options=$2
    local do_log=$(abcli_option_int "$options" log 0)

    pushd $path > /dev/null

    local filename
    for filename in *.sh ; do
        if [ "$do_log" == 1 ] ; then
            abcli_log "🔹 ${filename%.*}"
        fi

        source $filename
    done
    popd > /dev/null
}