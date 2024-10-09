#! /usr/bin/env bash

function abcli_env_backup() {
    local task=$1

    if [ "$task" == "help" ]; then
        abcli_show_usage "@env backup" \
            "backup env -> $abcli_path_env_backup."
        abcli_show_usage "@env backup list" \
            "list $abcli_path_env_backup."
        return
    fi

    if [ "$task" == "list" ]; then
        abcli_list $abcli_path_env_backup
        return
    fi

    mkdir -pv $abcli_path_env_backup

    pushd $abcli_path_git >/dev/null
    local repo_name
    for repo_name in $(ls -d */); do
        repo_name=$(basename $repo_name)

        [[ -f $repo_name/.env ]] &&
            cp -v \
                $repo_name/.env \
                $abcli_path_env_backup/$repo_name.env
    done
    popd >/dev/null

    cp -v \
        "$HOME/Library/Application Support/Code/User/settings.json" \
        $abcli_path_env_backup/vscode-settings.json

    cp -rv \
        ~/.ssh \
        $abcli_path_env_backup/.ssh

    cp -rv \
        ~/.aws \
        $abcli_path_env_backup/.aws

    abcli_log "ℹ️ make sure $abcli_path_env_backup is synced with Google Drive."
}
