#! /usr/bin/env bash

function abcli_initialize() {
    if [[ "$abcli_is_docker" == false ]] &&
        [[ "$abcli_is_aws_batch" == false ]]; then
        git config --global user.email "arash@kamangir.net"
        git config --global user.name "kamangir"
        git config --global credential.helper store
    fi

    [[ "$abcli_is_docker" == false ]] &&
        [[ "$abcli_is_in_notebook" == false ]] &&
        [[ "$abcli_is_aws_batch" == false ]] &&
        [[ "$abcli_is_github_workflow" == false ]] &&
        abcli_add_ssh_keys

    export abcli_host_name=$(python3 -m abcli.modules.host get --keyword name)

    [[ "$abcli_is_in_notebook" == true ]] && return

    abcli_set_prompt

    abcli_update_terminal_title
}
