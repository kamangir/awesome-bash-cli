#! /usr/bin/env bash

function awesome_bash_cli_template_session() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "start" ] ; then
        abcli_log "awesome-bash-cli-template: session started."

        python3 -m awesome_bash_cli_template.session.start ${@:3}

        abcli_log "awesome-bash-cli-template: session ended."
        return
    fi

    abcli_log_error "-awesome-bash-cli-template: session: $task: command not found."
}