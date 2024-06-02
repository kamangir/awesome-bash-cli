#! /usr/bin/env bash

function abcli_badge() {
    local note=$1
    [[ "$note" == "clear" ]] && note=""

    if [[ "$note" == "help" ]]; then
        abcli_show_usage "@badge <note>" \
            "badge <note>."
        return
    fi

    echo -e "\033]1337;SetBadgeFormat=$(echo -n "$note" | base64)\a"
}
