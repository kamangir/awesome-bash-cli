#! /usr/bin/env bash

function abcli_aws_json_get() {
    python3 -c "from abcli import file; print(file.load_json('$abcli_path_bash/bootstrap/config/aws.json')[1]$1)"
}

function abcli_aws_region() {
    abcli_aws_json_get "['region']"
}

function abcli_aws_s3_bucket() {
    abcli_aws_json_get "['s3']['bucket_name']"
}