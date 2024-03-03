#! /usr/bin/env bash

function abcli_test() {
    local options=$1
    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options=""
        [[ "$plugin_name" == abcli ]] && options="$EOP,plugin=<plugin-name>$EOPE"
        abcli_show_usage "$plugin_name test list$options" \
            "list $plugin_name tests."

        options="${EOP}what=all|<test-name>,dryrun"
        local test_options="dryrun,upload$EOPE"
        abcli_show_usage "$plugin_name test$ABCUL$options$ABCUL$test_options" \
            "test $plugin_name."
        return
    fi

    local repo_name=$(abcli_unpack_repo_name $plugin_name)
    local subfolder=".abcli"
    [[ "$plugin_name" == "abcli" ]] &&
        subfolder="bash"
    local test_folder=$abcli_path_git/$repo_name/$subfolder/tests

    if [ $(abcli_option_int "$options" list 0) == 1 ]; then
        abcli_list "$test_folder/*.sh"
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)

    local list_of_tests=$(abcli_option "$options" what all)
    if [[ "$list_of_tests" == all ]]; then
        list_of_tests=""
        pushd $test_folder >>/dev/null
        local filename
        for filename in *.sh; do
            list_of_tests="$list_of_tests ${filename%.*}"
        done
        popd >/dev/null
    fi
    abcli_log_list "$list_of_tests" \
        --delim space \
        --after "test(s)"

    local test_name
    for test_name in $list_of_tests; do
        abcli_eval dryrun=$do_dryrun \
            test_${plugin_name}_${test_name} \
            "$test_options" \
            "${@:3}"
    done
}

abcli_source_path \
    $abcli_path_abcli/bash/tests
