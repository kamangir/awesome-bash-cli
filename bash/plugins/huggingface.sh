#! /usr/bin/env bash

function abcli_huggingface() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name git clone repo_1" \
            "clone huggingface/repo_1."
        abcli_help_line "$abcli_cli_name huggingface install" \
            "install huggingface."
        abcli_help_line "$abcli_cli_name huggingface save repo_1 name_1 object_1 [force]" \
            "[force] save object_1 as huggingface/repo_1/name_1."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.huggingface --help
        fi
        return
    fi

    if [ $task == "clone" ] ; then
        pushd $abcli_path_git > /dev/null
        git clone https://huggingface.co/kamangir/$2
        popd > /dev/null
        return
    fi

    if [ $task == "install" ] ; then
        python3 -m pip install huggingface_hub
        huggingface-cli login
        return
    fi

    if [ $task == "save" ] ; then
        local repo_name=$(abcli_unpack_keyword "$2")
        local model_name=$(abcli_clarify_arg "$3" "$repo_name")
        local object_name=$(abcli_clarify_object "$4" $abcli_object_name)

        local options=$5
        local do_force=$(abcli_option_int "$options" "force" 0)

        if [ -d "$abcli_path_git/$repo_name/saved_model/$model_name" ] && [ "$do_force" == 0 ] ; then
            abcli_log_error "-abcli: huggingface: save: $model_name: already exists."
            return
        fi

        abcli_log "releasing $object_name as $repo_name/$model_name: $options"

        abcli_download object $object_name

        pushd $abcli_path_git/$repo_name > /dev/null

        mkdir -p saved_model/$model_name

        cp -av $abcli_object_path/. saved_model/$model_name/

        find . -name "*.jpg" -type f -delete

        git status

        return
    fi

    abcli_log_error "-abcli: huggingface: $task: command not found."
}