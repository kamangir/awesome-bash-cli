#! /usr/bin/env bash

export abcli_path_bash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function abcli_main() {
    source $abcli_path_bash/bootstrap/dependencies.sh
    abcli_source_dependencies

    local options=$1
    local do_terraform=1
    if [ "$abcli_is_mac" == true ] ; then
        local do_terraform=0
    fi
    local do_terraform=$(abcli_option_int "$options" terraform $do_terraform)

    if [ "$do_terraform" == 1 ] ; then
        abcli_terraform
    fi

    abcli_initialize

    if [ "$abcli_is_jupyternotebook" == true ] ; then
        abcli_log "📃  welcome to Jupyter Notebook + $abcli_fullname!"
    else
        abcli_select $abcli_object_name
    fi

    local command="${@:2}"
    if [ ! -z "$command" ] ; then
        abcli_log "abcli: running '$command'."
        eval $command
    fi
}

if [ -f "$abcli_path_bash/bootstrap/cookie/disabled" ] ; then
    printf "abcli is \033[0;31mdisabled\033[0m.\n"
else
    abcli_main $@
fi
