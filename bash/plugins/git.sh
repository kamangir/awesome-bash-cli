#! /usr/bin/env bash

function abcli_git() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli git <repo_name>" \
            "cd $abcli_path_git/<repo_name>."
        abcli_show_usage "abcli git cd$ABCUL<repo_name>" \
            "cd $abcli_path_git/<repo_name>."
        abcli_show_usage "abcli git clone$ABCUL<repo_name>$ABCUL[cd,~from_template,if_cloned,init,install,object,pull,source=<username/repo_name>]" \
            "clone <repo_name>."
        abcli_show_usage "abcli git create_branch$ABCUL<repo_name>$ABCUL<branch-name>" \
            "create branch <branch-name> in <repo_name>."

        abcli_git_pull $@

        abcli_show_usage "abcli git <repo_name>$ABCUL<command-args>" \
            "run 'git <command-args>' in $abcli_path_git/<repo_name>."
        abcli_show_usage "abcli git push$ABCUL<repo_name>$ABCUL[accept_no_issue,delete,first,object,~status]$ABCUL[<message>]" \
            "[first] push to <repo_name>."
        abcli_show_usage "abcli git recreate_ssh" \
            "recreate github ssh key."
        abcli_show_usage "abcli git select_issue$ABCUL<kamangir/bolt#abc>" \
            "select git issue."
        abcli_show_usage "abcli git sync_fork$ABCUL<repo-name>$ABCUL<branch-name>" \
            "sync fork w/ upstream."
        abcli_show_usage "abcli git status" \
            "git status."
        return
    fi

    local function_name="abcli_git_$task"
    if [[ $(type -t $function_name) == "function" ]] ; then
        $function_name ${@:2}
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $1)
    if [ -d "$abcli_path_git/$repo_name" ] ; then
        cd $abcli_path_git/$repo_name
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $2)

    if [ "$task" == "cd" ] ; then
        cd $abcli_path_git/$repo_name
        return
    fi

    if [ "$task" == "clone" ] ; then
        local options=$3
        local do_pull=$(abcli_option_int "$options" pull 0)
        local in_object=$(abcli_option_int "$options" object 0)
        local do_if_cloned=$(abcli_option_int "$options" if_cloned 0)
        local do_init=$(abcli_option_int "$options" init 0)
        local do_install=$(abcli_option_int "$options" install 0)
        local from_template=$(abcli_option_int "$options" from_template 1)
        local source=$(abcli_option "$options" source "")
        local then_cd=$(abcli_option_int "$options" cd 0)

        if [ "$in_object" == 0 ] ; then
            pushd $abcli_path_git > /dev/null
        fi

        # https://docs.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository
        # https://gist.github.com/0xjac/85097472043b697ab57ba1b1c7530274
        if [ ! -z "$source" ] ; then
            git clone --bare git@github.com:$source.git
            local source_repo_name=$(abcli_string_after $source /)
            mv $source_repo_name.git $repo_name

            cd $repo_name
            git push --mirror git@github.com:kamangir/$repo_name.git
            cd ..

            rm -rf $repo_name
        fi

        if [ ! -d "$repo_name" ] ; then
            git clone git@github.com:kamangir/$repo_name.git
        else
            if [ "$do_if_cloned" == 1 ] ; then
                local do_install=0
            fi
                
            if [ "$do_pull" == 1 ] ; then
                cd $repo_name
                git pull
                cd ..
            fi
        fi

        if [ "$do_init" == 1 ] ; then
            abcli_log "abcli: git: init: $repo_name"

            local module_name=$(echo $repo_name | tr - _)

            if [ "$from_template" == 0 ] ; then
                cp -Rv \
                    $abcli_path_git/blue-plugin/.abcli \
                    $abcli_path_git/$repo_name
                cp -Rv \
                    $abcli_path_git/blue-plugin/blue_plugin \
                    $abcli_path_git/$repo_name
                cp -v \
                    $abcli_path_git/blue-plugin/* \
                    $abcli_path_git/$repo_name
                cp -v \
                    $abcli_path_git/blue-plugin/.gitignore \
                    $abcli_path_git/$repo_name

                pushd $abcli_path_git/$repo_name > /dev/null
                mv -v \
                    .abcli/blue_plugin.sh \
                    .abcli/$module_name.sh
                mv -v \
                    .abcli/install/blue_plugin.sh \
                    .abcli/install/$module_name.sh
                mv -v \
                    blue_plugin \
                    $module_name
                popd > /dev/null
            else
                pushd $abcli_path_git/$repo_name > /dev/null
                git mv \
                    .abcli/blue_plugin.sh \
                    .abcli/$module_name.sh
                git mv \
                    .abcli/install/blue_plugin.sh \
                    .abcli/install/$module_name.sh
                git mv \
                    blue_plugin \
                    $module_name
                popd > /dev/null
            fi
        fi

        if [ "$do_install" == 1 ] ; then
            cd $repo_name
            pip3 install -e .
            cd ..
        fi

        if [ "$in_object" == 0 ] ; then
            popd > /dev/null
        fi

        if [ "$then_cd" == 1 ] ; then
            cd $abcli_path_git/$repo_name
        fi

        return
    fi

    if [ "$task" == "create_branch" ] ; then
        local branch_name=$3
        if [ -z "$branch_name" ] ; then
            abcli_log_error "-abcli: git: $task: branch not found."
            return 1
        fi

        pushd $abcli_path_git/$repo_name > /dev/null
        git pull
        git checkout -b $branch_name
        git push origin $branch_name
        popd > /dev/null

        return
    fi

    if [ "$task" == "push" ] ; then
        local options=$3
        local accept_no_issue=$(abcli_option_int "$options" accept_no_issue 0)
        local in_object=$(abcli_option_int "$options" object 0)
        local do_delete=$(abcli_option_int "$options" delete 0)
        local show_status=$(abcli_option_int "$options" status 1)
        local first_push=$(abcli_option_int "$options" first 0)

        if [ "$in_object" == 1 ] ; then
            pushd $abcli_object_path/$repo_name > /dev/null
        else
            pushd $abcli_path_git/$repo_name > /dev/null
        fi

        if [ "$show_status" == 1 ] ; then
            git status
        fi

        local message="${@:4}"

        if [ -z "$abcli_bolt_git_issue" ] ; then
            if [ "$accept_no_issue" == 0 ] ; then
                abcli_log_error "-abcli: git: issue not found."
                return
            fi
        else
            local message="$message - kamangir/bolt#$abcli_bolt_git_issue"
        fi

        git add .
        git commit -a -m "$message"

        if [ "$first_push" == 1 ] ; then
            local branch_name=$(abcli_git_get_branch $repo_name $options)
            git push --set-upstream origin $branch_name
        else
            git push
        fi

        if [ "$do_delete" == 1 ] ; then
            abcli_log "deleting $repo_name"
            cd ..
            rm -rf $repo_name
        fi

        popd > /dev/null

        return
    fi

    if [ "$task" == "recreate_ssh" ] ; then
        # https://www.cyberciti.biz/faq/sudo-append-data-text-to-file-on-linux-unix-macos/
        ssh-keyscan github.com | sudo tee -a ~/.ssh/known_hosts
        sudo ssh -T git@github.com
        return
    fi

    if [ "$task" == "select_issue" ] ; then
        abcli_select git_issue ${@:2}
        return
    fi

    if [ "$task" == "status" ] ; then
        pushd $abcli_path_git > /dev/null
        local repo_name
        for repo_name in $(ls -d */) ; do
            abcli_log $repo_name

            cd $repo_name
            git status
            cd ..
        done
        popd > /dev/null
        return
    fi

    if [ "$task" == "sync_fork" ] ; then
        local repo_name=$2
        local branch_name=$3

        # https://stackoverflow.com/a/7244456/17619982
        cd $abcli_path_git/$repo_name
        git fetch upstream
        git checkout $branch_name
        git rebase upstream/$branch_name
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $1)

    pushd $abcli_path_git/$repo_name > /dev/null
    git ${@:2}
    popd > /dev/null
}

function abcli_git_get_branch() {
    local repo_name=$(abcli_unpack_repo_name $1)

    local options=$2
    local in_object=$(abcli_option_int "$options" object 0)

    if [ "$in_object" == 1 ] ; then
        pushd $abcli_object_path/$repo_name > /dev/null
    else
        pushd $abcli_path_git/$repo_name > /dev/null
    fi

    # https://stackoverflow.com/a/1593487
    local branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
    local branch_name="master"     # detached HEAD

    popd > /dev/null

    local branch_name=${branch_name##refs/heads/}

    echo $branch_name
}

function abcli_get_git_branch() {
    abcli_get_version

    export abcli_git_branch=$(abcli_git_get_branch awesome-bash-cli)

    export abcli_fullname=abcli-$abcli_version.$abcli_git_branch
}

abcli_get_git_branch

function abcli_git_pull() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_show_usage "abcli git pull$ABCUL[~all,init]" \
            "pull [not all repos] [and init if version change]."
        return
    fi

    local abcli_fullname_before=$abcli_fullname

    local options=$1
    local do_all=$(abcli_option_int "$options" all 1)
    local do_init=$(abcli_option_int "$options" init 0)

    pushd $abcli_path_abcli > /dev/null
    git pull

    if [ "$do_all" == 1 ] ; then
        local repo
        local filename
        for repo in $(abcli_plugins list_of_external --delim space --log 0 --repo_names 1) ; do
            if [ -d "$abcli_path_git/$repo" ] ; then
                abcli_log $repo
                cd ../$repo
                git pull
                git config pull.rebase false
            fi
        done
    fi
    popd > /dev/null

    if [ "$do_init" == 0 ] ; then
        return
    fi

    abcli_get_git_branch

    if [ "$abcli_fullname" == "$abcli_fullname_before" ] ; then
        abcli_log "no version change: $abcli_fullname"
    else
        abcli_log "version change: $abcli_fullname_before -> $abcli_fullname"
        abcli_init
    fi
}