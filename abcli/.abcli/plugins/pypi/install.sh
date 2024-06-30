#! /usr/bin/env bash

function abcli_pypi_install() {
    local options=$1

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_show_usage "@pypi install" \
            "install pypi."
        return
    fi

    pip3 install --upgrade setuptools wheel twine
    python3 -m pip install --upgrade build
}
