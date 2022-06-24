#! /usr/bin/env bash

export abc_path_bash="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -f "$abc_path_bash/abc_disabled" ] ; then
    printf "abc is \033[0;31mdisabled\033[0m.\n"
else
    source $abc_path_bash/bootstrap/dependencies.sh
    abc_source_dependencies

    abc_init

    abc_terraform

    abc_select $abc_object_name
fi
