#! /usr/bin/env bash

function abcli_script() {
    local task=$(abcli_unpack_keyword $1 code)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli script$ABCUL[code]$ABCUL[<script-name>]" \
            "code <script-name>.sh."
        
        abcli_script_python $@

        abcli_show_usage "abcli script source$ABCUL[<script-name>]" \
            "source <script-name>.sh"
        abcli_show_usage "abcli script submit$ABCUL[<object-name>]$ABCUL[<tags>]" \
            "submit <object-name> as a job"
        return
    fi

    local function_name=abcli_script_$task
    if [[ $(type -t $function_name) == "function" ]] ; then
        $function_name ${@:2}
    fi

    if [ "$task" == "code" ] ; then
        abcli_tag set \
            $abcli_object_name \
            script,bash

        local script_name=$(abcli_clarify_input $2 script)

        if [ ! -f $script_name.sh ]; then
            cp -v $abcli_path_abcli/assets/script/script.sh ./$script_name.sh
        fi

        if [ "$abcli_is_mac" == true ] ; then
            code $script_name.sh
        else
            nano $script_name.sh
        fi

        return
    fi

    if [ "$task" == "source" ] ; then
        local script_name=$(abcli_clarify_input $2 script)

        chmod +x $script_name.sh
        source $script_name.sh
        return
    fi

    if [ "$task" == "submit" ] ; then
        abcli_tag set \
            "$2" \
            job,~completed,$3
        return
    fi

    abcli_log_error "-abcli: script: $task: command not found."
}

function abcli_script_python() {
    local task=$(abcli_unpack_keyword $1 code)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli script python$ABCUL[code]$ABCUL[cli|script]" \
            "code [cli|script].py"
        abcli_show_usage "abcli script python${ABCUL}run$ABCUL[<script-name>]$ABCUL[<args>]" \
            "run <script-name>.py."
        return
    fi

    abcli_tag set \
        $abcli_object_name \
        script,python

    local script_name=$(abcli_clarify_input $2 script)

    if [ "$task" == "code" ] ; then
        if [ ! -f $script_name.py ]; then
            cp -v $abcli_path_abcli/assets/script/$script_name.py ./$script_name.py
        fi

        if [ "$abcli_is_mac" == true ] ; then
            code $script_name.py
        else
            nano $script_name.py
        fi

        return
    fi

    if [ "$task" == "run" ] ; then
        python3 $script_name.py ${@:3}
        return
    fi

    abcli_log_error "-abcli: script: $task: command not found."
}

