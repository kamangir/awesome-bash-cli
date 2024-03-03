#! /usr/bin/env bash

function test_abcli_list() {
    local options=$1
    local do_dryrun=$(abcli_option_int "$options" dryrun 0)
    local do_upload=$(abcli_option_int "$options" upload 0)

    abcli_select

    abcli_list cloud

    abcli_list local

    abcli_list "$abcli_path_git/awesome-bash-cli/bash/tests/*.sh"
}
