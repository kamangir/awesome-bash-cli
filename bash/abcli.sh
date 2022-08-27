#! /usr/bin/env bash

export abcli_path_bash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function abcli_main() {
    source $abcli_path_bash/bootstrap/dependencies.sh
    abcli_source_dependencies

    local options=$1
    local do_terraform=$(abcli_option_int "$options" "terraform" 1)

    if [ "$do_terraform" == "1" ] ; then
        abcli_terraform
    fi

    abcli_initialize

    abcli_select $abcli_object_name
}

if [ -f "$abcli_path_bash/bootstrap/cookie/disabled" ] ; then
    printf "abcli is \033[0;31mdisabled\033[0m.\n"
else
    abcli_main $@
fi
