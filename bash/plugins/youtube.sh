#! /usr/bin/env bash

function abcli_youtube() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli youtube browse <video_id>" \
            "browse youtube/?v=<video_id>."
        abcli_help_line "abcli youtube cat <video_id>" \
            "cat info re youtube/?v=<video_id>."
        abcli_help_line "abcli youtube download <video_id>" \
            "download youtube/?v=<video_id>."
        abcli_help_line "abcli youtube duration <video_id>" \
            "print duration of youtube/?v=<video_id>."
        abcli_help_line "abcli youtube is_CC <video_id_1,video_id_2>" \
            "<True|False,True|False>."
        abcli_help_line "abcli youtube search <keyword>" \
            "search in youtube for <keyword>."
        abcli_help_line "abcli youtube install" \
            "install youtube."
        abcli_help_line "abcli youtube validate" \
            "validate youtube."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.plugins.youtube --help
        fi
        return
    fi

    if [ "$task" == "browse" ] ; then
        local video_id=$2
        local url="https://www.youtube.com/watch?v=$video_id"
        abcli_browse_url $url
        return
    fi

    if [ "$(abcli_list_in $task cat,download,duration,is_CC)" == "True" ] ; then
        local video_id=$2

        python3 -m abcli.plugins.youtube \
            $task \
            --video_id "$video_id" \
            ${@:3}

        if [ "$task" == "download" ] ; then
            abcli_tag set $abcli_object_name youtube_download
            abcli_relation set $video_id $abcli_object_name is-downloaded-in
        fi

        return
    fi

    if [ "$task" == "search" ] ; then
        python3 -m abcli.plugins.youtube \
            search \
            --keyword "$2" \
            ${@:3}
        return
    fi

    if [ "$task" == "install" ] ; then
        # https://medium.com/daily-python/python-script-to-search-content-using-youtube-data-api-daily-python-8-1084776a6578
        pip install google-api-python-client

        # https://medium.com/@sonawaneajinks/python-script-to-download-youtube-videos-daily-python-6-c3788be5b6b1
        pip install pytube

        # https://stackoverflow.com/a/16743442/17619982
        pip install isodate

        return
    fi

    if [ "$task" == "validate" ] ; then
        python3 -m abcli.plugins.youtube \
            validate \
            ${@:2}
        return
    fi

    abcli_log_error "unknown task: youtube '$task'."
}