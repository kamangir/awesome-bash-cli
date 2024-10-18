#! /usr/bin/env bash

function test_abcli_not() {
    abcli_assert \
        $(abcli_not 1) \
        0
    [[ $? -ne 0 ]] && return 1

    abcli_assert \
        $(abcli_not 0) \
        1
}
