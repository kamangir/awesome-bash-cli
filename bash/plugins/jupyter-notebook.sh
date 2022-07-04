#! /usr/bin/env bash

function abcli_notebook() {
    local task=$(abcli_unpack_keyword "$1" browse)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_name notebook [browse] [notebook] [args]" \
            "browse $abcli_object_name/notebook.ipynb [and pass args]."
        abcli_help_line "$abcli_name notebook build [notebook]" \
            "build $abcli_object_name/notebook.ipynb."
        abcli_help_line "$abcli_name notebook connect 1-2-3-4 [setup]" \
            "[setup and] connect to jupyter notebook on ec2:1-2-3-4."
        abcli_help_line "$abcli_name notebook host [setup]" \
            "[setup and] host jupyter notebook on ec2."
        return
    fi

    if [ "$task" == "build" ] || [ "$task" == "browse" ] ; then
        local notebook_name=$2
        if [ -z "$notebook_name" ] || [ "$notebook_name" == "-" ] ; then
            local notebook_name="notebook"
        fi

        export abcli_notebook_input="${@:3}"
    fi

    if [ "$task" == "build" ] ; then
        jupyter-nbconvert \
            $notebook_name.ipynb \
            -y --ExecutePreprocessor.timeout=-1 --execute --allow-errors \
            --to html \
            --output-dir $abcli_object_path

        mv $abcli_object_path/$notebook_name.html $abcli_object_path/$abcli_object_name.html

        return
    fi

    if [ "$task" == "browse" ] ; then
        if [ ! -f $notebook_name.ipynb ]; then
            cp $abcli_path_abcli/assets/notebook.ipynb ./$notebook_name.ipynb
            abcli_log "$notebook_name.ipynb copied."
        fi

        jupyter notebook

        return
    fi

    # https://docs.aws.amazon.com/dlami/latest/devguide/setup-jupyter.html
    if [ "$task" == "connect" ] ; then
        local options="$3"
        local do_setup=$(abcli_option_int "$options" "setup" 0)

        if [ "$do_setup" == 1 ] ; then
            local ip_address=$(echo "$2" | tr . -)
            ssh \
                -i $abcli_path_git/abcli/assets/aws/abcli.pem \
                -N -f -L 8888:localhost:8888 \
                ubuntu@ec2-$ip_address.$abcli_s3_region.compute.amazonaws.com
        fi

        open https://localhost:8888
        return
    fi

    if [ "$task" == "host" ] ; then
        local options="$2"
        local do_setup=$(abcli_option_int "$options" "setup" 0)

        if [ "$do_setup" == 1 ] ; then
            jupyter notebook password

            mkdir -p $abcli_path_home/ssl
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout $abcli_path_home/ssl/mykey.key \
                -out $abcli_path_home/ssl/mycert.pem
        fi

        jupyter notebook \
            --certfile=$abcli_path_home/ssl/mycert.pem \
            --keyfile $abcli_path_home/ssl/mykey.key

        return
    fi

    abcli_log_error "-abcli: jupyter-notebook: $task: command not found."
}
