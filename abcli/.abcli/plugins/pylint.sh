#! /usr/bin/env bash

export abcli_pylint_ignored=W1203,C0103,C0111,C0114,C0305,C0115,C0116,C0411,W0404,W0237,C0209,C0415,W0621,W0702,W0102,W1202,E0401,W1514,C3002,W0401,W0611,C0413,C0412,W0603,R0911,E1101,W0622,R1721,W0718,R1728,C3001,R0801,R0401,R0914,R0913,R0915,W0123,R0912,C0301,W0511,W0105,W0613,R0902,R0903,R1735,W1401,W3101,W1308,E1102,W0122,W0106,E1136,E1137

function abcli_pylint() {
    local options=$1

    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        local options=" - "
        [[ "$plugin_name" == "abcli" ]] && options="$ABCUL[ignore=<ignore>,plugin=<plugin-name>]"
        abcli_show_usage "$plugin_name pylint$options$ABCUL[<args>]" \
            "pylint $plugin_name."
        return
    fi

    abcli_pip install pylint

    local repo_name=$(abcli_unpack_repo_name $plugin_name)

    abcli_log "$plugin_name: pylint: repo=$repo_name"

    local ignore=$(abcli_option "$options" ignore voidvoidvoid)

    pushd $abcli_path_git/$repo_name >/dev/null
    pylint \
        -d $abcli_pylint_ignored \
        $(git ls-files '*.py' | grep -v $ignore) \
        "${@:2}"
    popd >/dev/null
}
