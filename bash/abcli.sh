#! /usr/bin/env bash

export abcli_status_icons=""

export abcli_path_bash="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function abcli_main() {
    export abcli_is_in_notebook=false
    [[ "$1" == "in_notebook" ]] && export abcli_is_in_notebook=true

    source $abcli_path_bash/bootstrap/dependencies.sh
    abcli_source_dependencies

    local options=$1
    local do_terraform=1
    [[ "$abcli_is_mac" == true ]] &&
        local do_terraform=0
    local do_terraform=$(abcli_option_int "$options" terraform $do_terraform)

    [[ "$do_terraform" == 1 ]] &&
        abcli_terraform

    abcli_initialize

    [[ "$abcli_is_in_notebook" == false ]] &&
        abcli_select $abcli_object_name

    local command="${@:2}"
    if [ ! -z "$command" ]; then
        abcli_log "abcli: running '$command'."
        eval $command
    fi
}

if [ -f "$abcli_path_bash/bootstrap/cookie/disabled" ]; then
    printf "abcli is \033[0;31mdisabled\033[0m.\n"
else
    abcli_main $@
fi
