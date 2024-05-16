#! /usr/bin/env bash

function abcli_pypi() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        local options="~download,dryrun,~upload"
        local args="[--<keyword-1> <value>]$ABCUL[--<keyword-2> <value>]"
        abcli_show_usage "abcli_ pypi <task-1>$ABCUL[$options]$ABCUL[.|<object-name-1>]$ABCUL[-|<object-name-2>]$ABCUL$args" \
            "<object-name-1> -[blue-plugin pypi <task-1>]-> <object-name-2>."

        abcli_show_usage "abcli_ pypi <task-2> ..." \
            "blue-plugin pypi <task-2> <object-name>."

        abcli_pypi_leaf "$@"
        return
    fi

    if [ "$task" == "<task-1>" ]; then
        local options=$2
        local do_dryrun=$(abcli_option_int "$options" dryrun 0)
        local do_download=$(abcli_option_int "$options" download $(abcli_not $do_dryrun))
        local do_upload=$(abcli_option_int "$options" upload $(abcli_not $do_dryrun))

        local object_name_1=$(abcli_clarify_object $3 .)
        local object_path_1=$abcli_object_root/$object_name_1

        [[ "$do_dryrun" == 1 ]] &&
            abcli_download - $object_name_1

        local object_name_2=$(abcli_clarify_object $4 $(abcli_string_timestamp))
        local object_path_2=$abcli_object_root/$object_name_2
        mkdir -p $object_path_2

        abcli_eval dryrun=$do_dryrun \
            "ls $object_path_1 >> $object_path_2/summary.txt"

        [[ "$do_dryrun" == 1 ]] &&
            abcli_upload - $object_name_2

        return
    fi

    local function_name=abcli_pypi_$task
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    if [ "$task" == "<task-2>" ]; then
        :
        return
    fi

    abcli_log_error "-abcli_: pypi: $task: command not found."
    return 1
}

abcli_source_path \
    $abcli_path_git/awesome-bash-cli/bash/plugins/pypi
