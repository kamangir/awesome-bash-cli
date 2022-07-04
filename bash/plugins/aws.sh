#! /usr/bin/env bash

function abcli_aws_json_get() {
    echo $(python3 -c "import abcli.file as file; print(file.load_json('$abcli_path_bash/bootstrap/config/aws.json')[1]$1)")
}