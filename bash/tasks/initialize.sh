#! /usr/bin/env bash

function abcli_initialize() {
    git config --global user.email "arash@kamangir.net"
    git config --global user.name "kamangir"
    git config --global credential.helper store

    abcli_add_ssh_keys

    export abcli_host_name=$(python3 -m abcli.tasks.host get --keyword name)

    abcli_set_prompt

    abcli_update_terminal_title
}