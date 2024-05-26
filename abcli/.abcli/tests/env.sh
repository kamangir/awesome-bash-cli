#! /usr/bin/env bash

function test_abcli_env() {
    abcli env
    abcli env path

    abcli env dot cat config
    abcli env dot cat sample
    abcli env dot cat nurah

    abcli env dot get TBD

    abcli env dot list
}
