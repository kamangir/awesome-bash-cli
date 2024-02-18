#! /usr/bin/env bash

export abcli_pylint_ignored=W1203,C0103,C0111,C0114,C0115,C0116,C0411,W0404,W0237,C0209,C0415,W0621,W0702,W0102,W1202,E0401,W1514,C3002,W0401,W0611,C0413,C0412,W0603,R0911,E1101,W0622,R1721,W0718,R1728,C3001,R0801,R0401,R0914,R0913,R0915,W0123,R0912

function abcli_pylint() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options="dryrun,install,log,plugin=<plugin-name>"
        abcli_show_usage "$plugin_name pylint$ABCUL[$options]$ABCUL[<args>]" \
            "pylint $plugin_name."
        return
    fi

    local do_install=$(abcli_option_int "$options" install 0)
    [[ -z "$(pip3 list | grep pylint)" ]] &&
        do_install=1

    [[ "$do_install" == 1 ]] &&
        abcli_eval $options, \
            "pip3 install pylint"

    local repo_name=$(abcli_unpack_repo_name $plugin_name)
    abcli_log "abcli: pylint: plugin=$plugin_name, repo=$repo_name"

    abcli_eval "path=$abcli_path_git/$repo_name,$options" \
        "abcli_pylint_internal ${@:2}"
}

function abcli_pylint_internal() {
    pylint -d $abcli_pylint_ignored $(git ls-files '*.py') "$@"
}
