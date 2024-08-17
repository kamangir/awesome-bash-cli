#! /usr/bin/env bash

function abcli_env_dot_edit() {
    local machine_kind=$(abcli_clarify_input $1 local)

    if [[ "$machine_kind" == "help" ]]; then
        abcli_show_usage "@env dot edit${ABCUL}jetson_nano|rpi$ABCUL<machine-name>" \
            "edit .env on machine."
        return
    fi

    local machine_name=$2

    if [ "$machine_kind" == "local" ]; then
        nano $abcli_path_abcli/.env
    else
        local filename="$abcli_object_temp/scp-${machine_kind}-${machine_name}.env"

        abcli_scp \
            $machine_kind \
            $machine_name \
            \~/git/awesome-bash-cli/.env \
            - \
            - \
            $filename

        nano $filename

        abcli_scp \
            local \
            - \
            $filename \
            $machine_kind \
            $machine_name \
            \~/git/awesome-bash-cli/.env
    fi
}
