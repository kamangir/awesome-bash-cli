#! /usr/bin/env bash

function test_abcli_env() {
    local options=$1
    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_upload=$(abcli_option_int "$options" upload 0)

    abcli env
    abcli env path

    abcli env dot cat
    abcli env dot cat sample
    abcli env dot cat nurah

    abcli env dot get TBD

    abcli env dot list
}
