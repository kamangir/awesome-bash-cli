#! /usr/bin/env bash

function abc_source_dependencies() {
    source $abc_path_bash/bootstrap/consts.sh
    source $abc_path_bash/bootstrap/logging.sh

    local module_name
    local script_filename
    for module_name in abc plugins ; do
        local names=""
        for script_filename in $abc_path_bash/$module_name/*.sh ; do
            local names="$names $(basename $script_filename .sh)"
            source $script_filename
        done
        if [ "$module_name" == "plugins" ] ; then
            echo "names:|$names|"
            abc_log_list "$names" space "plugin(s)" "loaded "
        fi
    done
}