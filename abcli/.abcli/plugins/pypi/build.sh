#! /usr/bin/env bash

export abcli_pypi_build_options="${EOP}browse,install,~rm_dist,~upload$EOPE"

function abcli_pypi_build() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local callable=$([[ "$plugin_name" == "abcli" ]] && echo "@" || echo "$plugin_name ")
        options=$abcli_pypi_build_options
        [[ "$plugin_name" == abcli ]] && options="$options$EOP,plugin=<plugin-name>$EOPE"
        abcli_show_usage "${callable}pypi build$ABCUL$options" \
            "$plugin_name -> pypi."
        return
    fi

    local do_install=$(abcli_option_int "$options" install 0)
    local do_upload=$(abcli_option_int "$options" upload 1)
    local do_browse=$(abcli_option_int "$options" browse 0)
    local rm_dist=$(abcli_option_int "$options" rm_dist 1)

    [[ "$do_install" == 1 ]] &&
        abcli_pypi_install

    local repo_name=$(abcli_unpack_repo_name $plugin_name)
    if [[ ! -d "$abcli_path_git/$repo_name" ]]; then
        abcli_log "-@pypi: build: $repo_name: repo not found."
        return 1
    fi

    abcli_log "pypi: building $plugin_name ($repo_name)..."

    pushd $abcli_path_git/$repo_name >/dev/null

    python3 -m build
    [[ $? -ne 0 ]] && return 1

    [[ "$do_upload" == 1 ]] &&
        twine upload dist/*

    [[ "$rm_dist" == 1 ]] &&
        rm -v dist/*

    popd >/dev/null

    [[ "$do_browse" == 1 ]] &&
        abcli_pypi_browse "$@"

    return 0
}
