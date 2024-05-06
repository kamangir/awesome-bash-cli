#! /usr/bin/env bash

function abcli_storage() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli storage clear" \
            "clear storage."
        abcli_show_usage "abcli storage download_file$ABCUL<object-name> [filename]" \
            "download filename -> <object-name>."
        abcli_show_usage "abcli storage exists$ABCUL<object-name>" \
            "True/False."
        abcli_show_usage "abcli storage list$ABCUL<prefix> [<args>]" \
            "list prefix in storage."
        abcli_show_usage "abcli storage rm|remove$ABCUL[~dryrun]$ABCUL<object-name>" \
            "remove <object-name>."
        abcli_show_usage "abcli storage status$ABCUL[count=<10>,depth=<2>]" \
            "show storage status."

        if [ "$(abcli_keyword_is $2 verbose)" == true ]; then
            python3 -m abcli.plugins.storage --help
        fi
        return
    fi

    if [[ "$task" == "clear" ]]; then
        cd
        sudo rm -rf $abcli_path_storage/*
        abcli_select $abcli_object_name
        return
    fi

    if [[ "$task" == "download_file" ]]; then
        python3 -m abcli.plugins.storage \
            download_file \
            --object_name $2 \
            --filename $3 \
            ${@:4}
        return
    fi

    if [[ "$task" == "exists" ]]; then
        python3 -m abcli.plugins.storage \
            exists \
            --object_name $2 \
            ${@:3}
        return
    fi

    if [[ "$task" == "list" ]]; then
        python3 -m abcli.plugins.storage \
            list_of_objects \
            --prefix $2 \
            ${@:3}
        return
    fi

    if [[ "|remove|rm|" == *"|$task|"* ]]; then
        local options=$2
        local do_dryrun=$(abcli_option_int "$options" dryrun 1)

        local object_name=$(abcli_clarify_object $3)
        if [[ -z "$object_name" ]]; then
            abcli_log_error "-abcli: storage: $task: object-name not found."
            return 1
        fi

        abcli_eval dryrun=$do_dryrun \
            rm -rfv $abcli_object_root/$object_name

        return
    fi

    if [ "$task" == "status" ]; then
        local options=$2
        local count=$(abcli_option_int "$options" count 10)
        local depth=$(abcli_option_int "$options" depth 2)
        local do_dryrun=$(abcli_option_int "$options" dryrun 0)

        abcli_eval dryrun=$do_dryrun,path=$abcli_path_storage \
            "du -hc -d $depth | sort -h -r | head -n $count"

        return
    fi

    abcli_log_error "-abcli: storage: $task: command not found."
    return 1
}
