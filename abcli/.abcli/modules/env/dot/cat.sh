#! /usr/bin/env bash

function abcli_env_dot_cat() {
    local env_name=$(abcli_clarify_input $1 .env)

    if [[ "$env_name" == "help" ]]; then
        abcli_show_usage "@env dot cat$ABCUL[|<env-name>|config|sample]" \
            "cat .env|<env-name>|sample.env."

        abcli_show_usage "@env dot cat${ABCUL}jetson_nano|rpi <machine-name>" \
            "cat .env from machine."
        return
    fi

    if [[ "$env_name" == ".env" ]]; then
        pushd $abcli_path_abcli >/dev/null
        abcli_eval - \
            dotenv list --format shell
        popd >/dev/null
        return
    fi

    if [ "$(abcli_list_in $env_name rpi,jetson_nano)" == True ]; then
        local machine_kind=$1
        local machine_name=$2

        local filename="$abcli_path_temp/scp-${machine_kind}-${machine_name}.env"

        abcli_scp \
            $machine_kind \
            $machine_name \
            \~/git/awesome-bash-cli/.env \
            - \
            - \
            $filename

        cat $filename

        return
    fi

    if [[ "$env_name" == "config" ]]; then
        abcli_eval - \
            cat $abcli_path_abcli/abcli/config.env
        return
    fi

    if [[ "$env_name" == "sample" ]]; then
        abcli_eval - \
            cat $abcli_path_abcli/sample.env
        return
    fi

    abcli_eval - \
        cat $abcli_path_assets/env/$env_name.env
}
