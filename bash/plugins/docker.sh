#! /usr/bin/env bash

function abcli_docker() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli docker build$ABCUL[run]" \
            "build [and run] abcli image."
        abcli_show_usage "abcli docker run$ABCUL[]" \
            "run abcli image."
        return
    fi

    local options=$2

    local filename="Dockerfile"
    local tag="kamangir/abcli"

    if [ "$task" == "build" ] ; then
        local do_run=$(abcli_option_int "$options" run 0)

        pushd $abcli_path_abcli > /dev/null

        mkdir -p temp
        cp -v ~/.kaggle/kaggle.json temp/

        abcli_log "docker: building $filename: $tag"

        docker build \
            --build-arg HOME=$HOME \
            -t $tag \
            -f $filename \
            .

        rm -rf temp

        if [ "$do_run" == "1" ] ; then
            abcli_docker run $options
        fi

        popd > /dev/null

        return
    fi

    if [ "$task" == "run" ] ; then
        abcli_log "docker: running $filename: $tag: $options"

        pushd $abcli_path_abcli > /dev/null
        # https://gist.github.com/mitchwongho/11266726
        docker run -it $tag /bin/bash
        popd > /dev/null

        return
    fi

    abcli_log_error "unknown task: docker '$task'."
}