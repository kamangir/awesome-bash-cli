#! /usr/bin/env bash

function abcli_initialize() {
    abcli_set_log_verbosity

    git config --global user.email "arash@kamangir.net"
    git config --global user.name "kamangir"
    git config --global credential.helper store

    export abcli_host_name=$(python3 -m abcli.tasks.host get --keyword name)
}