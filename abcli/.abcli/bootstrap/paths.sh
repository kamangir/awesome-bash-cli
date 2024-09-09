#! /usr/bin/env bash

export abcli_path_abcli=$(python3 -c "import os;print(os.sep.join('$abcli_path_bash'.split(os.sep)[:-2]))")
export abcli_path_git=$(python3 -c "import os;print(os.sep.join('$abcli_path_abcli'.split(os.sep)[:-1]))")

export ABCLI_PATH_STORAGE="$HOME/storage"

mkdir -pv $ABCLI_PATH_STORAGE

export ABCLI_OBJECT_ROOT="$ABCLI_PATH_STORAGE/abcli"
export abcli_path_temp="$ABCLI_PATH_STORAGE/temp"

mkdir -pv $abcli_path_temp

export abcli_path_ignore=$abcli_path_temp/ignore

mkdir -pv $abcli_path_ignore

export abcli_path_assets=$abcli_path_abcli/abcli/assets
