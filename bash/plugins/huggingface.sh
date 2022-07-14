#! /usr/bin/env bash

function abcli_huggingface() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_cli_name git clone repo_1" \
            "clone huggingface/repo_1."
        abcli_help_line "$abcli_cli_name huggingface install" \
            "install huggingface."
        abcli_help_line "$abcli_cli_name huggingface predict model_repo_1 object_1 [name_1] [object]" \
            "run model_repo_1 saved/object model name_1 predict on object_1."
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

    if [ "$task" == "predict" ] ; then
        # 5: options: e.g. "~object"

        local repo_name=$(abcli_unpack_keyword "$2")
        local data_object=$(abcli_clarify_object "$3" $abcli_object_name)

        abcli_download object $data_object

        local options=$5
        local model_is_object=$(abcli_option_int "$options" "object" 0)

        if [ "$model_is_object" == 1 ] ; then
            local model_object=$(abcli_clarify_object "$4")

            abcli_download object $model_object

            local model_path=$abcli_object_root/$model_object
        else
            local model_name=$(abcli_clarify_arg "$4")

            local model_path=$abcli_path_git/image-classifier/saved_model/$model_name
        fi
        if [ ! -d "$model_path" ] ; then
            abcli_log_error "-abcli: huggingface: predict: $model_path: path not found."
            return
        fi

        abcli_log "huggingface($repo_name:$model_path).predict($data_object): $options"

        python3 -m $(echo $repo_name | tr - _) \
            predict \
            --data_path $abcli_object_root/$data_object \
            --model_path $model_path \
            --output_path $abcli_object_path \
            ${@:6}

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

        rm -rf saved_model/$model_name/auxiliary

        find . -name "*.jpg" -type f -delete

        git status

        return
    fi

    abcli_log_error "-abcli: huggingface: $task: command not found."
}