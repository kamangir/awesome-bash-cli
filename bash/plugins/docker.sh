#! /usr/bin/env bash

function abcli_docker() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_show_usage "abcli docker build$ABCUL[~push,run]" \
            "build [and run] abcli image."

        abcli_show_usage "abcli docker clear$ABCUL[-]" \
            "clear docker."

        abcli_docker compose help

        abcli_show_usage "abcli docker push" \
            "push abcli image."

        abcli_show_usage "abcli docker run" \
            "run abcli image."

        abcli_show_usage "abcli docker seed" \
            "seed docker 🌱."
        return
    fi

    local options=$2

    local filename="Dockerfile"
    local tag="kamangir/abcli"

    if [ "$task" == compose ]; then
        local sub_task=$2

        local options=$3
        local do_push=$(abcli_option_int "$options" push 1)

        if [[ "$sub_task" == help ]]; then
            abcli_show_usage "abcli docker compose build$ABCUL[~push,run]" \
                "build [and run] abcli image using docker-compose."
            abcli_show_usage "abcli docker compose run" \
                "run abcli image using docker-compose."
            return 1
        fi

        local command_line=""
        [[ "$sub_task" == "build" ]] && local command_line="docker-compose up"
        [[ "$sub_task" == "run" ]] && local command_line="docker-compose run -it abcli"

        if [[ -z "$command_line" ]]; then
            abcli_log_error "-abcli: docker: $task: $sub_task: command not found."
            return 1
        fi

        abcli_eval \
            path=$abcli_path_abcli \
            "$command_line"

        [[ "$do_push" == "1" ]] &&
            abcli_eval - \
                "docker push $tag:latest"

        return
    fi

    if [ "$task" == "build" ]; then
        local do_push=$(abcli_option_int "$options" push 1)
        local do_run=$(abcli_option_int "$options" run 0)

        pushd $abcli_path_abcli >/dev/null

        mkdir -p temp
        cp -v ~/.kaggle/kaggle.json temp/

        abcli_log "docker: building $filename: $tag"

        docker build \
            --build-arg HOME=$HOME \
            -t $tag \
            -f $filename \
            .

        rm -rf temp

        [[ "$do_push" == "1" ]] &&
            abcli_eval - \
                "docker push $tag:latest"

        [[ "$do_run" == "1" ]] &&
            abcli_docker run $options

        popd >/dev/null

        return
    fi

    if [ "$task" == "clear" ]; then
        abcli_eval - \
            "docker image prune"
        abcli_eval - \
            "docker system prune"
        return
    fi

    if [ "$task" == "push" ]; then
        abcli_eval - \
            "docker push $tag:latest"
        return
    fi

    if [ "$task" == "run" ]; then
        abcli_log "docker: running $filename: $tag: $options"

        pushd $abcli_path_abcli >/dev/null
        # https://gist.github.com/mitchwongho/11266726
        docker run -it $tag /bin/bash
        popd >/dev/null

        return
    fi

    if [ "$task" == "seed" ]; then
        abcli_seed docker "${@:2}"
        return
    fi

    abcli_log_error "-abcli: docker: $task: command not found."
}
