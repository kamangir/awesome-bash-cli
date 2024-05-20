#! /usr/bin/env bash

function abcli_latex() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_latex build "$@"
        return
    fi

    if [ "$task" == "build" ]; then
        local options=$2

        if [ $(abcli_option_int "$options" help 0) == 1 ]; then
            local options="dryrun"
            abcli_show_usage "@latex build$ABCUL[$options]$ABCUL<path/filename.tex>" \
                "build <path/filename.tex>."
            return
        fi

        local do_dryrun=$(abcli_option_int "$options" dryrun 0)

        local full_path=$3
        if [[ ! -f "$full_path" ]]; then
            abcli_log_error "-abcli: latex: $task: $full_path: file not found."
            return 1
        fi
        path=$(dirname "$full_path")
        filename=$(basename "$full_path")
        filename=${filename%.*}
        abcli_log "building $path / $filename.tex..."

        pushd $path >/dev/null

        rm -v $filename.dvi
        rm -v $filename.ps

        abcli_eval dryrun=$do_dryrun \
            latex \
            -interaction=nonstopmode \
            $filename.tex

        #abcli_eval dryrun=$do_dryrun \
        #    makeindex $filename.idx

        abcli_eval dryrun=$do_dryrun \
            dvips \
            -o $filename.ps \
            $filename.dvi

        abcli_eval dryrun=$do_dryrun \
            ps2pdf $filename.ps

        popd >/dev/null

        return
    fi

    abcli_log_error "-abcli: latex: $task: command not found."
    return 1
}
