#! /usr/bin/env bash

function abcli_help() {
    local keyword=$1

    if [ "$(abcli_keyword_is $keyword help)" == true ] ; then
        abcli_help_line "help [task]" \
            "show help [for task]."
        return
    fi

    local temp_file=$abcli_path_git/temp.sh

    # https://stackoverflow.com/a/5927391/17619982
    # https://ma.ttias.be/grep-show-lines-before-and-after-the-match-in-linux/
    cat $(find $abcli_path_bash -type f -name "*.sh") | grep -A 1 "abcli_help_line \""  | grep -v -- "^--$" > $temp_file

    python3 -m abcli.help \
        sort \
        --filename $temp_file

    chmod +x $temp_file
    source $temp_file | grep "$keyword"
    rm $temp_file
}