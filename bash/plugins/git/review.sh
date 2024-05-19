#! /usr/bin/env bash

function abcli_git_review() {
    local repo_name=$(abcli_git_get_repo_name)

    pushd $abcli_path_git/$repo_name >/dev/null

    local list_of_files=$(git diff --name-only HEAD | tr "\n" " ")
    local list_of_files=$(abcli_list_nonempty "$list_of_files" --delim space)
    if [[ -z "$list_of_files" ]]; then
        abcli_log_warning "-abcli: git: review: no changes."
        popd >/dev/null
        return
    fi

    local char="x"
    local index=0
    local count=$(abcli_list_len "$list_of_files" --delim=space)
    while true; do
        local index=$(python3 -c "print(min($count-1,max(0,$index)))")
        local filename=$(abcli_list_item "$list_of_files" $index --delim space)

        clear
        git status
        abcli_hr
        printf "📜 $RED$filename$NC\n"

        if [[ "$filename" == *.ipynb ]]; then
            abcli_log_warning "jupyter notebook, will not review."
        else
            git diff $filename
        fi

        abcli_hr
        abcli_log "# Enter|space: next - p: previous - q: quit."
        read -n 1 char
        [[ "$char" == "q" ]] && break
        [[ -z "$char" ]] && ((index++))
        [[ "$char" == "p" ]] && ((index--))

        $(python3 -c "print(str($index >= $count).lower())") && break
    done

    popd >/dev/null
}
