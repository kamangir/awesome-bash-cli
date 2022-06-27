#! /usr/bin/env bash

function abcli_source_dependencies() {
    source $abcli_path_bash/bootstrap/consts.sh
    source $abcli_path_bash/bootstrap/logging.sh

    local module_name
    local script_filename
    for module_name in abcli install tasks plugins ; do
        local names=""
        for script_filename in $abcli_path_bash/$module_name/*.sh ; do
            local names="$names $(basename $script_filename .sh)"
            source $script_filename
        done
        if [ "$module_name" == "plugins" ] ; then
            abcli_log_list "$names" space "plugin(s)" "loaded "
        fi
    done
}