#! /usr/bin/env bash

export abcli_path_abcli=$(python3 -c "import os;print(os.sep.join('$abcli_path_bash'.split(os.sep)[:-2]))")
export abcli_path_git=$(python3 -c "import os;print(os.sep.join('$abcli_path_abcli'.split(os.sep)[:-1]))")
export abcli_path_home=$(python3 -c "import os;print(os.sep.join('$abcli_path_git'.split(os.sep)[:-1]))")
export abcli_path_storage="$abcli_path_home/storage"
export abcli_object_root="$abcli_path_storage/abcli"
export abcli_path_ignore=$abcli_path_abcli/assets/ignore
export abcli_path_temp=$abcli_path_storage/temp

mkdir -p $abcli_path_storage
mkdir -p $abcli_path_temp
