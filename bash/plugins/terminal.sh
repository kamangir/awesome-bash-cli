#! /usr/bin/env bash

function abcli_get_icon() {
    local icon=""
    if [ "$abcli_is_docker" == true ]; then
        if [ "$abcli_is_sagemaker" == true ]; then
            if [ "$abcli_is_sagemaker_system" == true ]; then
                local icon="⚗️ "
            else
                local icon="🧪 "
            fi
        else
            local icon="🌠 "
        fi
    elif [ "$abcli_is_ec2" == true ]; then
        local icon="🌩️ "
    elif [ "$abcli_is_jetson" == true ] || [ "$abcli_is_rpi" == true ]; then
        local icon="⚡ "
    elif [ "$abcli_is_mac" == true ]; then
        local icon="💻 "
    fi

    echo "$abcli_status_icons$icon"
}

function abcli_set_prompt() {
    # https://askubuntu.com/a/946716
    force_color_prompt=yes
    color_prompt=yes

    parse_git_branch() {
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    # https://misc.flogisoft.com/bash/tip_colors_and_formatting
    if [ "$color_prompt" = yes ]; then
        PS1=$(abcli_get_icon)'\[\033[00;32m\]$abcli_fullname\[\033[00m\]:${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\n > '
    else
        PS1=$(abcli_get_icon)'$abcli_fullname${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
    fi
    unset color_prompt force_color_prompt
}

function abcli_update_terminal_title() {
    local title="$(abcli_get_icon) $abcli_fullname"
    [[ "$abcli_is_sagemaker" == false ]] && [[ "$abcli_is_shell" == false ]] &&
        local title="$title@$(hostname)"

    [ $# -gt 0 ] &&
        local title="$title | $@"

    echo -n -e "\033]0;$title\007"
}
