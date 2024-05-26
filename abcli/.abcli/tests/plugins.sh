#! /usr/bin/env bash

function test_abcli_plugin_name_from_repo() {
    local options=$1

    if [[ "$abcli_is_github_workflow" == true ]]; then
        abcli_log_warning "plugins are not present in the github workflow."
        return
    fi

    abcli_assert \
        $(abcli_plugin_name_from_repo awesome-bash-cli) \
        abcli

    abcli_assert \
        $(abcli_plugin_name_from_repo CV) \
        CV

    abcli_assert \
        $(abcli_plugin_name_from_repo roofAI) \
        roofAI

    abcli_assert \
        $(abcli_plugin_name_from_repo vancouver-watching) \
        vancouver_watching

    abcli_assert \
        $(abcli_plugin_name_from_repo giza) \
        giza

    abcli_assert \
        $(abcli_plugin_name_from_repo hubble) \
        hubble

    abcli_assert \
        $(abcli_plugin_name_from_repo aiart) \
        aiart
}

function test_abcli_get_module_name_from_plugin() {
    if [[ "$abcli_is_github_workflow" == true ]]; then
        abcli_log_warning "plugins are not present in the github workflow."
        return
    fi

    abcli_assert \
        $(abcli_get_module_name_from_plugin abcli) \
        abcli

    abcli_assert \
        $(abcli_get_module_name_from_plugin CV) \
        abadpour

    abcli_assert \
        $(abcli_get_module_name_from_plugin roofAI) \
        roofAI

    abcli_assert \
        $(abcli_get_module_name_from_plugin vancouver_watching) \
        vancouver_watching

    abcli_assert \
        $(abcli_get_module_name_from_plugin giza) \
        gizai

    abcli_assert \
        $(abcli_get_module_name_from_plugin hubble) \
        hubblescope

    abcli_assert \
        $(abcli_get_module_name_from_plugin aiart) \
        articraft
}
