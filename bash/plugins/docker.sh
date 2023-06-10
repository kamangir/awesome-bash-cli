#! /usr/bin/env bash

function abcli_docker() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "docker build [run,slim,~start_with_abcli]" \
            "build [and run] docker image."
        abcli_show_usage "docker run [~abcli,slim]" \
            "run docker image."
        return
    fi

    local options=$2
    local slim=$(abcli_option_int "$options" slim 0)

    local filename="Dockerfile"
    local tag="kamangir/abcli"
    if [ "$slim" == 1 ] ; then
        local filename="Dockerfile-slim"
        local tag="kamangir/abcli/slim"
    fi

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
        local start_with_abcli=$(abcli_option_int "$options" start_with_abcli 1)

        abcli_log "docker: running $filename: $tag: $options"

        pushd $abcli_path_abcli > /dev/null
        if [ "$start_with_abcli" == 1 ] ; then
            docker run -it \
                --entrypoint "/bin/bash -c 'source /root/git/awesome-bash-cli/bash/abcli.sh && /bin/bash'" \
                $tag
        else
            # https://gist.github.com/mitchwongho/11266726
            docker run -it $tag /bin/bash
        fi
        popd > /dev/null

        return
    fi

    abcli_log_error "unknown task: docker '$task'."
}