#! /usr/bin/env bash

function abcli_job() {
    local task=$(abcli_unpack_keyword $1 help)
    local operation=$3

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli job completed <job-name> <operation>" \
            "register that <job-name> is completed for <operation>."
        abcli_help_line "abcli job count <tag_1,tag_2> <operation>" \
            "count number of jobs for <operation> given <tag_1,tag_2>."
        abcli_help_line "abcli job find <tag_1,tag_2> <operation>" \
            "find a job for <operation> given <tag_1,tag_2>."
        abcli_help_line "abcli job started <job-name> <operation>" \
            "register that <job-name> started <operation>."
        return
    fi

    if [ "$task" == "completed" ] ; then
        local job_name=$2
        abcli_tag set $job_name completed_$operation,~started_$operation
        return
    fi
    
    if [ "$task" == "count" ] ; then
        local tags="$2,~started_$operation,~completed_$operation"
        abcli_tag search $tags --show_count 1
        return
    fi

    if [ "$task" == "find" ] ; then
        local tags="$2,~started_$operation,~completed_$operation"
        abcli_tag search $tags --count 1 --raw 1
        return
    fi

    if [ "$task" == "started" ] ; then
        local job_name=$2
        abcli_tag set $job_name started_$operation
        return
    fi

    abcli_log_error "-abcli: job: $task: command not found."
}