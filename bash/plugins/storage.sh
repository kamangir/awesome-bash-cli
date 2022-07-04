#! /usr/bin/env bash

function abcli_storage() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "storage clear" \
            "clear storage."
        abcli_help_line "storage download_file object_name [filename]" \
            "download object_name -> filename."
        abcli_help_line "storage exists object_name" \
            "True/False."
        abcli_help_line "storage list prefix [args]" \
            "list prefix in storage."
        abcli_help_line "storage status" \
            "show storage status."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.storage --help
        fi
        return
    fi

    if [[ "$task" == "clear" ]]; then
        rm -rf $abcli_path_storage/*
        cd
        abcli_select $abcli_asset_name
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

    if [[ "$task" == "list" ]] ; then
        python3 -m abcli.plugins.storage \
            list_of_objects \
            --prefix $2 \
            ${@:3}
        return
    fi

    if [[ "$task" == "clear" ]]; then
        cd    
        rm -rf $abcli_path_storage/*
        abcli_select $abcli_object_name
        return
    fi

    abcli_log_error "-abcli: storage: $task: command not found."
}