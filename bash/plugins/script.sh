#! /usr/bin/env bash

function abcli_script() {
    local task=$(abcli_unpack_keyword $1 code)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli script [code] [<script-name>]" \
            "code $abcli_object_name/<script-name>.sh."
        
        abcli_script_python $@

        abcli_help_line "abcli script source [<script-name>]" \
            "source $abcli_object_name/<script-name>.sh"
        abcli_help_line "abcli script submit [<tags>]" \
            "submit $abcli_object_name/script.sh to worker [w/ <tags>]"
        return
    fi

    if [[ $(type -t abcli_script_$task) == "function" ]] ; then
        abcli_script_$task ${@:2}
    fi

    abcli_tag set $abcli_object_name script,bash

    local script_name=$(abcli_clarify_input $2 script)

    if [ "$task" == "code" ] ; then
        if [ ! -f $script_name.sh ]; then
            cp $abcli_path_abcli/assets/script/script.sh ./$script_name.sh
            echo $script_name.sh copied.
        fi

        if [ "$abcli_is_mac" == true ] ; then
            code $script_name.sh
        else
            nano $script_name.sh
        fi

        return
    fi

    if [ "$task" == "source" ] ; then
        chmod +x $script_name.sh
        source $script_name.sh
        return
    fi

    if [ "$task" == "submit" ] ; then
        abcli_tag set $abcli_object_name work,~completed,$2
        return
    fi

    abcli_log_error "-abcli: script: $task: command not found."
}

function abcli_script_python() {
    local task=$(abcli_unpack_keyword $1 code)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli script python [code] [cli|script]" \
            "code $abcli_object_name/[cli|script].py"
        abcli_help_line "abcli script python run [<script-name>]" \
            "run $abcli_object_name/<script-name>.py."
        return
    fi

    abcli_tag set $abcli_object_name script,python

    local script_name=$(abcli_clarify_input $2 script)

    if [ "$task" == "code" ] ; then
        if [ ! -f $script_name.py ]; then
            cp $abcli_path_abcli/assets/script/$script_name.py ./$script_name.py
            echo $script_name.py copied.
        fi

        if [ "$abcli_is_mac" == true ] ; then
            code $script_name.py
        else
            nano $script_name.py
        fi

        return
    fi

    if [ "$task" == "run" ] ; then
        python3 $script_name.py ${@:4}
        return
    fi

    abcli_log_error "-abcli: script: $task: command not found."
}

