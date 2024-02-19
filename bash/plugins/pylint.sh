#! /usr/bin/env bash

export abcli_pylint_ignored=W1203,C0103,C0111,C0114,C0115,C0116,C0411,W0404,W0237,C0209,C0415,W0621,W0702,W0102,W1202,E0401,W1514,C3002,W0401,W0611,C0413,C0412,W0603,R0911,E1101,W0622,R1721,W0718,R1728,C3001,R0801,R0401,R0914,R0913,R0915,W0123,R0912

function abcli_pylint() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "abcli pylint$ABCUL[<args>]" \
            "pylint abcli."
        return
    fi

    pip3 install pylint

    pushd $abcli_path_git/awesome-bash-cli >/dev/null
    pylint \
        -d $abcli_pylint_ignored \
        $(git ls-files '*.py') \
        "${@:2}"
    popd >/dev/null
}
