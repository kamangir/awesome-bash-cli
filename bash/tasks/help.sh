#! /usr/bin/env bash

function abcli_help() {
    local keyword=$1

    if [ "$(abcli_keyword_is $keyword help)" == true ] ; then
        abcli_help_line "$abcli_cli_name help [task]" \
            "show help [for task]."
        return
    fi

    local temp_file=$abcli_path_git/temp.sh

    # https://stackoverflow.com/a/5927391/17619982
    # https://ma.ttias.be/grep-show-lines-before-and-after-the-match-in-linux/
    cat $(find $abcli_path_bash -type f -name "*.sh") | grep -A 1 "abcli_help_line \""  | grep -v -- "^--$" > $temp_file

    local plugin
    local filename
    local external_plugins=$(abcli_external_plugins)
    for plugin in $(echo "$external_plugins" | tr _ -) ; do
        if [ -d "$abcli_path_git/$plugin" ] ; then
            for filename in $abcli_path_git/$plugin/abcli/*.sh ; do
                cat $filename | grep -A 1 "abcli_help_line \""  | grep -v -- "^--$" >> $temp_file
            done
        fi
    done

    python3 -c "from abcli.bash import help; help.sort('$temp_file')"

    chmod +x $temp_file
    source $temp_file | grep "$keyword"
    rm $temp_file
}