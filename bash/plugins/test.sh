#! /usr/bin/env bash

function abcli_test() {
    local options=$1
    local plugin_name=$(abcli_option "$options" plugin abcli)

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        options="list"
        [[ "$plugin_name" == abcli ]] && options="$options$EOP,plugin=<plugin-name>$EOPE"
        abcli_show_usage "$plugin_name test$ABCUL$options" \
            "list $plugin_name tests."

        options="${EOP}what=all|<test-name>,dryrun"
        local test_options="dryrun$EOPE"
        abcli_show_usage "$plugin_name test$ABCUL$options$ABCUL$test_options" \
            "test $plugin_name."
        return
    fi

    if [ $(abcli_option_int "$options" list 0) == 1 ]; then
        local plugin_name_=$(echo $plugin_name | tr - _)
        declare -F | awk '{print $3}' | grep test_${plugin_name_}
        return
    fi

    local do_dryrun=$(abcli_option_int "$options" dryrun 0)

    local list_of_tests=$(abcli_option "$options" what all)
    [[ "$list_of_tests" == all ]] &&
        list_of_tests=$(abcli_test list,plugin=$plugin_name | tr "\n" " ")
    abcli_log_list "$list_of_tests" \
        --delim space \
        --after "test(s)"

    local test_name
    local failed_test_list=
    for test_name in $list_of_tests; do
        abcli_eval dryrun=$do_dryrun \
            $test_name \
            "$test_options" \
            "${@:3}"
        if [ $? -ne 0 ]; then
            abcli_log "$test_name: failed."
            failed_test_list=$failed_test_list,$test_name
        fi
    done

    failed_test_list=$(abcli_list_nonempty $failed_test_list)
    if [[ -z "$failed_test_list" ]]; then
        return
    else
        abcli_log_list $list_of_tests \
            --after "failed test(s)" \
            --before ""
        return 1
    fi
}

abcli_source_path \
    $abcli_path_abcli/bash/tests
