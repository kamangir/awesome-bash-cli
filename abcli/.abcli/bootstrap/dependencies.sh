#! /usr/bin/env bash

function abcli_source_dependencies() {
    source $abcli_path_bash/bootstrap/paths.sh
    source $abcli_path_bash/bootstrap/system.sh
    source $abcli_path_bash/bootstrap/logging.sh
    source $abcli_path_bash/bootstrap/install.sh
    source $abcli_path_bash/bootstrap/source.sh

    python3 -m blueness version \
        --show_icon 1

    source $(python -m blue_options locate)/.bash/blue_options.sh

    local module_name
    for module_name in abcli modules plugins; do
        pushd $abcli_path_bash/$module_name >/dev/null

        if [ "$module_name" == "plugins" ]; then
            local plugins=($(ls *.sh))
            local plugins=${plugins[*]}
            local plugins=$(python3 -c "print('$plugins'.replace('.sh',''))")
            [[ "$abcli_is_in_notebook" == false ]] &&
                abcli_log_list "$plugins" \
                    --before "loading" \
                    --delim space \
                    --after "plugin(s)"
        fi

        local filename
        for filename in *.sh; do
            source $filename
        done
        popd >/dev/null
    done

    [[ "$abcli_is_in_notebook" == true ]] && return

    local repo_name
    for repo_name in $(abcli_plugins list_of_external --log 0 --delim space --repo_names 1); do
        local module_name=$(abcli_plugins get_module_name $repo_name)
        pushd $abcli_path_git/$repo_name/$module_name/.abcli >/dev/null

        local filename
        for filename in *.sh; do
            source $filename
        done
        popd >/dev/null
    done

    local list_of_installed_plugins=$(abcli_plugins list_of_installed \
        --log 0 \
        --delim space)
    if [[ -z "$list_of_installed_plugins" ]]; then
        abcli_log "🌀 no pip-installed plugins."
        return 0
    else
        abcli_log_list "$list_of_installed_plugins" \
            --before "🌀 loading" \
            --delim space \
            --after "pip-installed plugin(s)"

        local paths_of_installed_plugins=$(abcli_plugins list_of_installed \
            --log 0 \
            --delim space \
            --return_path 1)
        for module_path in $paths_of_installed_plugins; do
            #abcli_log "🔵 $module_path"
            pushd $module_path >/dev/null

            local filename
            for filename in *.sh; do
                source $filename
            done
            popd >/dev/null
        done
    fi
}
