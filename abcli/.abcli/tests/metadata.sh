#! /usr/bin/env bash

function test_abcli_metadata() {
    local returned_value
    for post_func in {1..3}; do
        local object_name=$(abcli_string_timestamp)
        local object_path=$abcli_object_root/$object_name
        local filename=$object_path/metadata.yaml

        local key=$(abcli_string_random)
        local value=$(abcli_string_random)

        [[ "$post_func" == 1 ]] &&
            abcli metadata post \
                $key $value \
                filename \
                $filename \
                --verbose 1

        [[ "$post_func" == 2 ]] &&
            abcli metadata post \
                $key $value \
                object,filename=metadata.yaml \
                $object_name \
                --verbose 1

        [[ "$post_func" == 3 ]] &&
            abcli metadata post \
                $key $value \
                path,filename=metadata.yaml \
                $object_path \
                --verbose 1

        for get_func in {1..3}; do
            [[ "$get_func" == 1 ]] &&
                returned_value=$(abcli metadata get \
                    key=$key,filename \
                    $filename)

            [[ "$get_func" == 2 ]] &&
                returned_value=$(abcli metadata get \
                    key=$key,filename=metadata.yaml,object \
                    $object_name)

            [[ "$get_func" == 3 ]] &&
                returned_value=$(abcli metadata get \
                    key=$key,filename=metadata.yaml,path \
                    $object_path)

            abcli_assert "$value" "$returned_value"
        done
    done
}
