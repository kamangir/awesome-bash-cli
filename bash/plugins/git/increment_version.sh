#! /usr/bin/env bash

function abcli_git_increment_version() {
    local repo_name=$(abcli_unpack_repo_name .)

    ls $abcli_path_git/$repo_name >/dev/null
}
