#! /usr/bin/env bash

function abcli_git() {
    local task=$(abcli_unpack_keyword $1 help)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli git cd repo_name" \
            "cd $abcli_path_git/repo_name."
        abcli_help_line "abcli git clone repo_name [cd,object,pull,source=username/some_repo,terraform]" \
            "clone [and terraform] [a private fork of username/some_repo as] [$abcli_object_name/]repo_name [and pull if already exists]."

        abcli_git_pull $@

        abcli_help_line "abcli git repo_name command args" \
            "run 'git command args' in $abcli_path_git/repo_name."
        abcli_help_line "abcli git push repo_name [object,delete]" \
            "push to [and delete] [$abcli_object_name/]repo_name."
        abcli_help_line "abcli git recreate_ssh" \
            "recreate github ssh key."
        abcli_help_line "abcli git status" \
            "git status."
        return
    fi

    local function_name="abcli_git_$task"
    if [[ $(type -t $function_name) == "function" ]] ; then
        $function_name ${@:2}
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $2)

    if [ "$task" == "cd" ] ; then
        cd $abcli_path_git/$repo_name
        return
    fi

    if [ "$task" == "clone" ] ; then
        local options="$3"
        local do_pull=$(abcli_option_int "$options" "pull" 0)
        local in_object=$(abcli_option_int "$options" "object" 0)
        local source=$(abcli_option "$options" "source" "")
        local terraform=$(abcli_option_int "$options" "terraform" 0)
        local then_cd=$(abcli_option_int "$options" "cd" 0)

        if [ "$in_object" == "0" ] ; then
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

            if [ "$terraform" == "1" ] ; then
                cd $repo_name
                pip3 install -e .
                cd ..
            fi
        elif [ "$do_pull" == "1" ] ; then
            cd $repo_name
            git pull
            cd ..
        fi

        if [ "$in_object" == "0" ] ; then
            popd > /dev/null
        fi

        if [ "$then_cd" == "1" ] ; then
            cd $abcli_path_git/$repo_name
        fi

        return
    fi

    if [ "$task" == "push" ] ; then
        local options="$3"
        local in_object=$(abcli_option_int "$options" "object" 0)
        local do_delete=$(abcli_option_int "$options" "delete" 0)

        if [ "$in_object" == "1" ] ; then
            pushd $abcli_object_path/$repo_name > /dev/null
        else
            pushd $abcli_path_git/$repo_name > /dev/null
        fi

        git add .
        git commit -a -m "$abcli_fullname.git"
        git push
        popd > /dev/null

        if [ "$do_delete" == "1" ] ; then
            abcli_log "deleting $repo_name"
            rm -rf $repo_name
        fi

        return
    fi

    if [ "$task" == "recreate_ssh" ] ; then
        if [[ "$abcli_is_lite" == true ]] ; then
            # https://www.cyberciti.biz/faq/sudo-append-data-text-to-file-on-linux-unix-macos/
            local var=$(ssh-keyscan github.com)
            echo "$var" | sudo tee -a ~/.ssh/known_hosts
        else
            sudo ssh-keyscan github.com > ~/.ssh/known_hosts
        fi

        sudo ssh -T git@github.com
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

    if [ "$task" == "terraform" ] ; then
        if [ -z "$repo_name" ] ; then
            abcli_log_error "-abcli.git: terraform: missing repo_name."
            return
        fi

        abcli_log "git.terraform($repo_name)"

        pushd $abcli_path_git > /dev/null

        if [ ! -d "$repo_name" ] ; then
            git clone git@github.com:kamangir/$repo_name.git
        fi

        cd $repo_name
        pip3 install -e .

        popd > /dev/null
        return
    fi


    local repo_name=$(abcli_unpack_repo_name $1)

    pushd $abcli_path_git/$repo_name > /dev/null
    git ${@:2}
    popd > /dev/null
}

function abcli_get_git_branch() {
    # https://stackoverflow.com/a/1593487
    pushd $abcli_path_abcli > /dev/null
    branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
    branch_name="master"     # detached HEAD
    popd > /dev/null

    abcli_get_version

    export abcli_git_branch=${branch_name##refs/heads/}
    export abcli_fullname=abcli-$abcli_version.$abcli_git_branch
}

abcli_get_git_branch

function abcli_git_pull() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "abcli git pull [-all,init]" \
            "pull [not all repos] [and init if version change]."
        return
    fi

    local abcli_fullname_before=$abcli_fullname

    local options=$1
    local do_all=$(abcli_option_int "$options" "all" 1)
    local do_init=$(abcli_option_int "$options" "init" 0)

    pushd $abcli_path_abcli > /dev/null
    git pull

    if [ "$do_all" == "1" ] ; then
        local repo
        local filename
        local external_plugins=$(abcli_external_plugins space)
        for repo in $(echo "$external_plugins" | tr _ -) ; do
            if [ -d "$abcli_path_git/$repo" ] ; then
                abcli_log $repo
                cd ../$repo
                git pull
                git config pull.rebase false
            fi
        done
    fi
    popd > /dev/null

    if [ "$do_init" == "0" ] ; then
        return
    fi

    abcli_get_version
    abcli_get_git_branch

    if [ "$abcli_fullname" == "$abcli_fullname_before" ] ; then
        abcli_log "no version change: $abcli_fullname"
    else
        abcli_log "version change: $abcli_fullname_before -> $abcli_fullname"
        abcli_init
    fi
}