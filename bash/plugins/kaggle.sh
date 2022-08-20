#! /usr/bin/env bash

function abcli_kaggle() {
    local task=$(abcli_unpack_keyword "$1")

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli kaggle install" \
            "install kaggle."
        return
    fi

    if [ "$task" == "install" ] ; then
        if [[ "$abcli_is_mac" == true ]] || [[ "$abcli_is_ec2" == true ]] ; then
            # https://github.com/Kaggle/kaggle-api
            pip3 install kaggle
            mkdir -p ~/.kaggle/
            cp -v $abcli_path_bash/bootstrap/config/kaggle.json ~/.kaggle/
            chmod 600 ~/.kaggle/kaggle.json
        fi

        return
    fi

    abcli_log_error "-abcli: notebook: $task: command not found."
}
