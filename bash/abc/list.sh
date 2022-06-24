#! /usr/bin/env bash

function abc_list_in() {
    local item="$1"
    local items="$2"

    local delim="$3"
    if [ -z "$delim" ] ; then
        local delim=","
    fi
    if [[ "$delim" == "space" ]] ; then
        local delim=" "
    fi

    python3 -c "print('True' if '$item' in '$items'.split('$delim') else 'False')"
}

function abc_list_len() {
    local items="$1"

    local delim="$2"
    if [ -z "$delim" ] ; then
        local delim=","
    fi
    if [[ "$delim" == "space" ]] ; then
        local delim=" "
    fi

    python3 -c "print(len('$items'.split('$delim')) if '$items' else 0)"
}

function abc_list_nonempty() {
    local items="$1"

    local delim="$2"
    if [ -z "$delim" ] ; then
        local delim=","
    fi
    if [[ "$delim" == "space" ]] ; then
        local delim=" "
    fi

    python3 -c "print('$delim'.join([thing for thing in '$items'.split('$delim') if thing]))"
}

function abc_list_resize() {
    local items="$1"

    local delim="$2"
    if [ -z "$delim" ] ; then
        local delim=","
    fi
    if [[ "$delim" == "space" ]] ; then
        local delim=" "
    fi

    local count="$3"

    python3 -c "print('$delim'.join(('$items'.split('$delim'))[:$count]))"
}

function abc_list_sort() {
    local items="$1"

    local delim="$2"
    if [ -z "$delim" ] ; then
        local delim=","
    fi
    if [[ "$delim" == "space" ]] ; then
        local delim=" "
    fi

    python3 -c "print('$delim'.join(sorted('$items'.split('$delim'))))"
}