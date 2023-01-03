#! /usr/bin/env bash

function abcli_docker() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "docker build [run]" \
            "build [and run] docker image."
        abcli_show_usage "docker run" \
            "run docker image."
        return
    fi

    if [ "$task" == "build" ] ; then
        local options="$2"
        local do_run=$(abcli_option_int "$options" run 0)

        pushd $abcli_path_abcli > /dev/null

        mkdir -p temp
        cp -v ~/.ssh/kamangir_git temp/
        cp -v ~/.kaggle/kaggle.json temp/

        docker build \
            --build-arg branch_name=$abcli_git_branch \
            --build-arg home=$abcli_path_home \
            --build-arg user=$USER \
            -t kamangir/abcli \
            .

        rm -rfv temp

        if [ "$do_run" == "1" ] ; then
            abcli_docker run
        fi

        popd > /dev/null

        return
    fi

    if [ "$task" == "run" ] ; then
        pushd $abcli_path_abcli > /dev/null
        # https://gist.github.com/mitchwongho/11266726
        docker run -it kamangir/abcli
        popd > /dev/null

        return
    fi

    abcli_log_error "unknown task: docker '$task'."
}