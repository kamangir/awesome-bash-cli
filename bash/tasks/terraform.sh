#! /usr/bin/env bash

function abcli_ec2_terraform_get() {
    echo $(python3 -c "import abcli.file as file; print(file.load_json('$abcli_path_bash/bootstrap/config/aws.json')[1]['ec2']$1)")
}

function abcli_terraform() {
    local task=$(abcli_unpack_keyword $1)

    if [ "$task" == "help" ] ; then
        abcli_help_line "$abcli_name terraform disable" \
            "disable terraform."
        abcli_help_line "$abcli_name terraform enable" \
            "enable terraform."

        if [ "$(abcli_keyword_is $2 verbose)" == true ] ; then
            python3 -m abcli.terraform --help
        fi
        return
    fi

    if [ "$task" == "disable" ] ; then
        touch $abcli_path_bash/abcli_disabled
        return
    fi

    if [ "$task" == "enable" ] ; then
        rm $abcli_path_bash/abcli_disabled
        return
    fi

    # wip
}
