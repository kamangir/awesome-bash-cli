#! /usr/bin/env bash

function abcli_select() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli select [<object_name>] [open,~trail]" \
            "select [object_name] [no trail]."
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

    export abcli_object_name_prev=$abcli_object_name
    export abcli_object_name=$object_name
    
    export abcli_object_path=$abcli_object_root/$abcli_object_name
    mkdir -p $abcli_object_path

    cd $abcli_object_path

    if [ "$update_trail" == 1 ] ; then
        abcli_trail $abcli_object_path/$abcli_object_name
    fi

    abcli_log "📂 $abcli_object_name"

    if [ "$do_open" == 1 ] ; then
        open $abcli_object_path
    fi
}