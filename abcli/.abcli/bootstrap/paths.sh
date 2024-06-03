#! /usr/bin/env bash

export abcli_path_abcli=$(python3 -c "import os;print(os.sep.join('$abcli_path_bash'.split(os.sep)[:-2]))")
export abcli_path_git=$(python3 -c "import os;print(os.sep.join('$abcli_path_abcli'.split(os.sep)[:-1]))")

export abcli_path_storage="$HOME/storage"

mkdir -pv $abcli_path_storage

export abcli_object_root="$abcli_path_storage/abcli"
export abcli_path_temp="$abcli_path_storage/temp"

mkdir -pv $abcli_path_temp

export abcli_path_ignore=$abcli_path_temp/ignore

mkdir -pv $abcli_path_ignore

export abcli_path_assets=$abcli_path_abcli/abcli/assets
