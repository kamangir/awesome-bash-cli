#! /usr/bin/env bash

function abcli_git() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ]; then
        abcli_show_usage "@git <repo_name> <command-line>" \
            "run '@git <command-line>' in <repo_name>."

        abcli_git increment_version "$@"
        abcli_git browse "$@"
        abcli_git create_branch "$@"
        abcli_git clone "$@"
        abcli_git get_repo_name "$@"
        abcli_git pull $@
        abcli_git push "$@"
        abcli_git recreate_ssh "$@"
        abcli_git reset "$@"
        abcli_git review "$@"
        abcli_git seed $@
        abcli_git status "$@"
        abcli_git sync_fork "$@"
        return
    fi

    if [ "$task" == "++" ]; then
        abcli_git increment_version "${@:2}"
        return
    fi

    if [ "$task" == "seed" ]; then
        abcli_seed git "${@:2}"
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $1)
    if [ -d "$abcli_path_git/$repo_name" ]; then
        if [[ -z "${@:2}" ]]; then
            cd $abcli_path_git/$repo_name
            return
        fi

        pushd $abcli_path_git/$repo_name >/dev/null
        abcli_git "${@:2}"
        popd >/dev/null

        return
    fi

    if [[ "$2" == "help" ]]; then
        local options
        case $task in
        browse)
            options="${EOP}actions$EOPE"
            abcli_show_usage "@git browse $options" \
                "browse the repo."
            ;;
        clone)
            options="${EOP}cd,~from_template,if_cloned,init,install,object,pull,source=<username/repo_name>$EOPE"
            abcli_show_usage "@git clone <repo-name>$ABCUL$options" \
                "clone <repo-name>."
            ;;
        create_branch)
            options="$EOP~increment_version,~push$EOPE"
            abcli_show_usage "@git create_branch <branch-name>$ABCUL$options" \
                "create <branch-name> in the repo."
            ;;
        create_pull_request)
            abcli_show_usage "@git create_pull_request" \
                "create a pull request in the repo."
            ;;
        get_branch)
            abcli_show_usage "@git get_branch" \
                "get brach name."
            ;;
        get_repo_name)
            abcli_show_usage "@git get_repo_name" \
                "get repo name."
            ;;
        increment_version)
            local options="diff"
            local args="--verbose 1"
            abcli_show_usage "@git ++|increment|increment_version$ABCUL$EOP$options$ABCUL$args$EOPE" \
                "increment repo version."
            ;;
        pull)
            options="$EOP~all,${EOPE}init"
            abcli_show_usage "@git pull $options" \
                "pull."
            ;;
        push)
            options="$EOP~action,browse,~create_pull_request,${EOPE}first$EOP,~increment_version,~status$EOPE"
            local build_options="build,$abcli_pypi_build_options"
            abcli_show_usage "@git push <message>$ABCUL$options$ABCUL$build_options" \
                "push to the repo."
            ;;
        recreate_ssh)
            abcli_show_usage "@git recreate_ssh" \
                "recreate github ssh key."
            ;;
        reset)
            abcli_show_usage "@git reset" \
                "reset to the latest commit of the current branch."
            ;;
        review)
            abcli_show_usage "@git review" \
                "review the repo."
            ;;
        sync_fork)
            abcli_show_usage "@git sync_fork <branch-name>" \
                "sync fork w/ upstream."
            ;;
        status)
            options="~all"
            abcli_show_usage "@git status $EOP$options$EOPE" \
                "git status."
            ;;
        *)
            abcli_log_error "-@git: $task: command not found."
            return 1
            ;;
        esac

        return
    fi

    local function_name="abcli_git_$task"
    if [[ $(type -t $function_name) == "function" ]]; then
        $function_name "${@:2}"
        return
    fi

    local repo_name=$(abcli_git_get_repo_name)
    if [[ "$repo_name" == "unknown" ]]; then
        abcli_log_error "-@git: $task: $(pwd): repo not found."
        return 1
    fi

    if [[ "$task" == "create_pull_request" ]]; then
        abcli_browse \
            https://github.com/kamangir/$repo_name/compare/$(abcli_git get_branch)?expand=1
        return
    fi

    if [[ "$task" == "get_branch" ]]; then
        # https://stackoverflow.com/a/1593487
        local branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
            local branch_name="master" # detached HEAD

        echo ${branch_name##refs/heads/}
        return
    fi

    if [ "$task" == "recreate_ssh" ]; then
        # https://www.cyberciti.biz/faq/sudo-append-data-text-to-file-on-linux-unix-macos/
        ssh-keyscan github.com | sudo tee -a ~/.ssh/known_hosts
        sudo ssh -T git@github.com
        return
    fi

    if [ "$task" == "reset" ]; then
        abcli_eval - "git reset --hard @{u}"
        return
    fi

    if [ "$task" == "sync_fork" ]; then
        local branch_name=$2

        # https://stackoverflow.com/a/7244456/17619982
        cd $abcli_path_git/$repo_name
        git fetch upstream
        git checkout $branch_name
        git rebase upstream/$branch_name
        return
    fi

    git "$@"
}

abcli_source_path - caller,suffix=/git

abcli_refresh_branch_and_version
