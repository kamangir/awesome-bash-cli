#! /usr/bin/env bash

export abcli_path_bash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -f "$abcli_path_bash/abcli_disabled" ] ; then
    printf "abcli is \033[0;31mdisabled\033[0m.\n"
else
    source $abcli_path_bash/bootstrap/dependencies.sh
    abcli_source_dependencies

    abcli_initialize

    abcli_terraform

    abcli_add_ssh_keys

    abcli_select $abcli_object_name
fi
