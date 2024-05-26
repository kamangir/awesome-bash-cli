#! /usr/bin/env bash

function abcli_refresh_branch_and_version() {
    export abcli_version=$(python3 -c "import abcli; print(abcli.VERSION)")

    export abcli_git_branch=$(abcli_git awesome-bash-cli get_branch)

    export abcli_fullname=abcli-$abcli_version.$abcli_git_branch
}

# internal function for abcli_seed.
function git_seed() {
    # seed is NOT local
    local user_email=$(git config --global user.email)
    seed="${seed}git config --global user.email \"$user_email\"$delim"

    local user_name=$(git config --global user.name)
    seed="${seed}git config --global user.name \"$user_name\"$delim_section"
}
