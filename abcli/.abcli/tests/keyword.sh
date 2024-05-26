#! /usr/bin/env bash

function test_abcli_keyword_is() {
    abcli_assert \
        $(abcli_keyword_is V verbose) \
        true

    abcli_assert \
        $(abcli_keyword_is "" verbose) \
        false

    abcli_assert \
        $(abcli_keyword_is verbose) \
        false

    abcli_assert \
        $(abcli_keyword_is v verbose) \
        false
}

function test_abcli_pack_keyword() {
    abcli_assert \
        $(abcli_pack_keyword verbose) \
        V
}

function test_abcli_unpack_keyword() {
    abcli_assert \
        $(abcli_unpack_keyword V) \
        verbose
}

function test_abcli_unpack_repo_name() {
    abcli_assert \
        $(abcli_unpack_repo_name abcli) \
        awesome-bash-cli
}
