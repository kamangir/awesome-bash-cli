#! /usr/bin/env bash

function abcli_conda() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_conda create "$@"
        abcli_conda exists "$@"
        abcli_conda list "$@"
        abcli_conda remove "$@"
        return
    fi

    if [[ "$2" == "help" ]]; then
        local options
        case $task in
        create)
            options="${EOP}clone=<auto|base>,~install_plugin,${EOPE}name=<environment-name>${EOP},repo=<repo-name>,~recreate${EOP}"
            abcli_show_usage "@conda create$ABCUL$options" \
                "create conda environment."
            ;;
        exists)
            abcli_show_usage "@conda exists$ABCUL[<environment-name>]" \
                "does conda environment exist? true|false."
            ;;
        list)
            abcli_show_usage "@conda list" \
                "show list of conda environments."
            ;;
        remove | rm)
            abcli_show_usage "@conda remove|rm$ABCUL[<environment-name>]" \
                "remove conda environment."
            ;;
        *)
            abcli_log_error "-@conda: $task: command not found."
            return 1
            ;;
        esac

        return
    fi

    if [[ ",remove,rm," == *",$task,"* ]]; then
        local environment_name=$(abcli_clarify_input $2 abcli)

        conda activate base
        conda remove -y --name $environment_name --all

        return
    fi

    if [ "$task" == "exists" ]; then
        local environment_name=$(abcli_clarify_input $2 abcli)

        if conda info --envs | grep -q "^$environment_name "; then
            echo 1
        else
            echo 0
        fi

        return
    fi

    if [ "$task" == "list" ]; then
        conda info --envs "${@:2}"
        return
    fi

    local function_name="abcli_conda_$task"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    conda "$@"
}

abcli_source_path - caller,suffix=/conda
