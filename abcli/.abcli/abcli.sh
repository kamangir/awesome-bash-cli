#! /usr/bin/env bash

export abcli_status_icons=""

export abcli_path_bash="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function abcli_main() {
    local options=$1

    if [[ ",$options," == *",verbose,"* ]]; then
        set -x
        touch $abcli_path_bash/../../verbose
    fi

    export abcli_is_silent=false
    [[ ",$options," == *",silent,"* ]] && export abcli_is_silent=true

    export abcli_is_in_notebook=false
    [[ ",$options," == *",in_notebook,"* ]] && export abcli_is_in_notebook=true

    export abcli_is_aws_batch=false
    [[ ",$options," == *",aws_batch,"* ]] && export abcli_is_aws_batch=true

    export abcli_is_colorful=true
    [[ "$abcli_is_aws_batch" == true ]] || [[ "$abcli_is_silent" == true ]] ||
        [[ ",$options," == *",mono,"* ]] &&
        export abcli_is_colorful=false

    source $abcli_path_bash/bootstrap/dependencies.sh
    abcli_source_dependencies

    local do_terraform=1
    [[ "$abcli_is_mac" == true ]] && do_terraform=0
    do_terraform=$(abcli_option_int "$options" terraform $do_terraform)

    [[ "$do_terraform" == 1 ]] &&
        abcli_terraform

    abcli_initialize

    [[ "$abcli_is_in_notebook" == false ]] &&
        abcli_select $abcli_object_name

    abcli_log "🚀 $abcli_fullname"

    local command_line="${@:2}"
    if [[ ! -z "$command_line" ]]; then
        abcli_eval - "$command_line"
        if [[ $? -ne 0 ]]; then
            abcli_log_error "abcli_main: failed: $command_line"
            return 1
        else
            abcli_log "✅ $command_line"
            return 0
        fi
    fi
}

if [ -f "$HOME/storage/temp/ignore/disabled" ]; then
    printf "abcli is \033[0;31mdisabled\033[0m, run '@T enable' first.\n"
else
    abcli_main "$@"
fi
