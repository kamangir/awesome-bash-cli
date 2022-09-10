#! /usr/bin/env bash

function abcli_set_prompt() {
    # https://askubuntu.com/a/946716
    force_color_prompt=yes
    color_prompt=yes

    parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    if [ "$color_prompt" = yes ]; then
        PS1='\[\033[00;32m\]$abcli_fullname\[\033[00m\]:${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\n > '
    else
        PS1='$abcli_fullname${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
    fi
    unset color_prompt force_color_prompt
}

function abcli_update_terminal_title() {
    title="$abcli_fullname@$(hostname)"
    if [ $# -gt 0 ]; then
        title="$title | $@"
    fi

    echo -n -e "\033]0;$title\007"
}