#! /usr/bin/env bash

function abcli_select() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli select [<object_name>] [open,plugin=<plugin>,~trail]" \
            "select [object_name]."
        abcli_show_usage "abcli select git_issue <abc>" \
            "select git issue kamangir/bolt#<abc>."
        return
    fi

    if [ "$task" == "git_issue" ] ; then
        export abcli_bolt_git_issue=$2
        abcli_log "#️⃣ git-issue: kamangir/bolt#$abcli_bolt_git_issue"
        return
    fi

    local object_name=$(abcli_clarify_object "$1" $(abcli_string_timestamp))

    local options=$2
    local update_trail=$(abcli_option_int "$options" trail 1)
    local do_open=$(abcli_option_int "$options" open 0)
    local plugin_name=$(abcli_option "$options" plugin abcli)

    local object_var=${plugin_name}_object_name
    export ${plugin_name}_object_name_prev=${!object_var}
    export ${plugin_name}_object_name=$object_name
    
    local path=$abcli_object_root/$object_name
    export ${plugin_name}_object_path=$path
    mkdir -p $path

    if [ "$plugin_name" == abcli ] ; then
        cd $abcli_object_path

        if [ "$update_trail" == 1 ] ; then
            abcli_trail $abcli_object_path/$abcli_object_name
        fi
    fi

    abcli_log "📂 $plugin_name: $abcli_object_name"

    if [ "$do_open" == 1 ] ; then
        open $abcli_object_path
    fi
}