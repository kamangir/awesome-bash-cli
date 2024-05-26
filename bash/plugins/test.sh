#! /usr/bin/env bash

function abcli_test() {
    local options=$1
    local plugin_name=$(abcli_option "$options" plugin abcli)

    local test_options=$2

    local plugin_display_name
    [[ "$plugin_name" == abcli ]] &&
        plugin_display_name="@" ||
        plugin_display_name="$plugin_name "

    if [ $(abcli_option_int "$options" help 0) == 1 ]; then
        abcli_test list,plugin=$plugin_name "$@"

        options="${EOP}what=all|<test-name>,dryrun$EOPE"
        local test_options="${EOP}dryrun$EOPE"
        abcli_show_usage "${plugin_display_name}test $options$ABCUL$test_options" \
            "test $plugin_name."

        [[ "$plugin_name" == abcli ]] &&
            abcli_show_usage "abcli_test$ABCUL$EOP$options,plugin=<plugin-name>$EOPE$ABCUL$test_options" \
                "test <plugin-name>."

        return
    fi

    if [ $(abcli_option_int "$options" list 0) == 1 ]; then
        if [ $(abcli_option_int "$2" help 0) == 1 ]; then
            [[ "$plugin_name" == abcli ]] &&
                abcli_show_usage "abcli_test list,plugin=<plugin-name>" \
                    "list <plugin-name> tests."

            abcli_show_usage "${plugin_display_name}test list" \
                "list $plugin_name tests."
            return
        fi

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
        --before "running" \
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

        abcli_hr
    done

    failed_test_list=$(abcli_list_nonempty $failed_test_list)
    if [[ -z "$failed_test_list" ]]; then
        return
    else
        abcli_log_list "$failed_test_list" \
            --after "failed test(s)" \
            --before ""
        return 1
    fi
}

abcli_source_path - caller,suffix=/../tests

function abcli_assert() {
    local value=$1
    local expected_value=$2

    local function_name="${FUNCNAME[1]}"

    if [[ "$expected_value" == "non-empty" ]]; then
        if [[ ! -z "$value" ]]; then
            abcli_log "✅ $function_name: $value is non-empty."
            return
        fi

        abcli_log_error "$function_name: empty value."
        return 1
    fi

    if [[ "$value" == "$expected_value" ]]; then
        abcli_log "✅ $function_name: $value == $expected_value."
        return
    fi

    abcli_log_error "$function_name: $value != $expected_value"
    return 1
}

function abcli_assert_list() {
    abcli_assert \
        $(abcli_list_sort "$1") \
        $(abcli_list_sort "$2")
}
