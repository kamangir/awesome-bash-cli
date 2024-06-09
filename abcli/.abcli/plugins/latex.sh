#! /usr/bin/env bash

export abcli_latex_build_options="bib=<name>,${EOP}dryrun,~ps,~pdf$EOPE"

function abcli_latex() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ]; then
        abcli_latex build "$@"
        return
    fi

    if [ "$task" == "build" ]; then
        local options=$2

        if [ $(abcli_option_int "$options" help 0) == 1 ]; then
            options=$abcli_latex_build_options
            abcli_show_usage "@latex build$ABCUL$options$ABCUL<path/filename.tex>" \
                "build <path/filename.tex>."
            return
        fi

        local do_dryrun=$(abcli_option_int "$options" dryrun 0)
        local do_ps=$(abcli_option_int "$options" ps 1)
        local do_pdf=$(abcli_option_int "$options" pdf 1)
        local bib_file=$(abcli_option "$options" bib)

        local full_path=$3
        if [[ ! -f "$full_path" ]]; then
            abcli_log_error "@latex: $task: $full_path: file not found."
            return 1
        fi
        path=$(dirname "$full_path")
        filename=$(basename "$full_path")
        filename=${filename%.*}
        abcli_log "building $path / $filename.tex..."

        pushd $path >/dev/null

        rm -v $filename.dvi
        rm -v $filename.ps

        local round
        for round in 1 2 3; do
            abcli_log "round $round..."

            abcli_eval dryrun=$do_dryrun \
                latex \
                -interaction=nonstopmode \
                $filename.tex

            [[ ! -z "$bib_file" ]] &&
                abcli_eval dryrun=$do_dryrun \
                    bibtex $bib_file
        done

        #abcli_eval dryrun=$do_dryrun \
        #    makeindex $filename.idx

        [[ "$do_ps" == 1 ]] &&
            abcli_eval dryrun=$do_dryrun \
                dvips \
                -o $filename.ps \
                $filename.dvi

        [[ "$do_pdf" == 1 ]] &&
            abcli_eval dryrun=$do_dryrun \
                ps2pdf $filename.ps

        popd >/dev/null

        return
    fi

    abcli_log_error "@latex: $task: command not found."
    return 1
}
