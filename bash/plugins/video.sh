#! /usr/bin/env bash

function abcli_create_video() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        # https://esahubble.org/press/video_formats/
        abcli_show_usage "abcli create_video [<.jpg>] [<filename>] [fps=<10>,~rm_frames,resize_to=<720x576>,scale=<1>]" \
            "$abcli_object_name/<.jpg> [-> <filename>.mp4]."
        return
    fi

    local suffix=$(abcli_clarify_input $1 .jpg)

    local video_filename=${suffix%%.*}
    local video_filename=$abcli_object_path/$(abcli_clarify_input $2 $video_filename).mp4
    if [ -f "$video_filename" ] ; then
        rm $video_filename
    fi

    local options="$3"
    local fps=$(abcli_option "$options" fps 10)
    local rm_frames=$(abcli_option_int "$options" rm_frames 1)
    local resize_to=$(abcli_option "$options" resize_to)
    local scale=$(abcli_option "$options" scale 1)

    local extension=$(basename -- "$suffix")
    local extension="${extension##*.}"

    if [ -d "temp_video" ] ; then
        rm -rf temp_video
    fi
    mkdir temp_video

    local filename
    local index=0
    local size=""
    for filename in *$suffix ; do
        local temp_filename=$abcli_object_path/temp_video/$index.$extension

        cp -v "$filename" $temp_filename

        if [ ! -z "$resize_to" ] ; then
            python3 -m abcli.plugins.video \
                resize \
                --filename $temp_filename \
                --size $resize_to  
        fi

        if [ -z "$size" ] ; then
            local size=$(python3 -m abcli.plugins.video size_of --filename $temp_filename --scale $scale)
        fi

        (( index++ ))
    done

    abcli_log "$abcli_object_name/$suffix -> $video_filename - $size - $fps fps - 1/$scale"

    ffmpeg \
        -f image2 \
        -r $fps \
        -i $abcli_object_path/temp_video/%d.$extension \
        -s $size \
        -vcodec h264 \
        $video_filename

    if [ "$rm_frames" == 1 ] ; then
        cp -v $abcli_object_path/temp_video/0.$extension $abcli_object_path/screenshot.$extension
        rm $abcli_object_path/*$suffix
    fi

    rm -rf $abcli_object_path/temp_video

    abcli_tag set $abcli_object_name video
}