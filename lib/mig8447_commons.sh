#!/bin/bash

# mig8447_commons.sh - mig8447 Bash Commons Version 1.2.0
#
# A Common Functions Library for Bash
#
# Changelog:
#    MODIFIED    VERSION    (MM/DD/YYYY)
#    mig8447     1.2.1      08/10/2018 - Improved logging
#                                      - Made script conform to shellcheck's
#                                        style guidelines
#    mig8447     1.2.0      08/10/2018 - Added script information
#    mig8447     1.2.0      08/09/2018 - Added get_alias_string function
#    mig8447     1.1.1      08/08/2018 - Bug fixes
#    mig8447     1.1.0      08/08/2018 - Added some comments
#                                      - Added add_path_to_path,
#                                        append_path_to_path and
#                                        prepend_path_to_path functions
#    mig8447     1.0.1      08/08/2018 - Added return value to
#                                        get_real_script_directory
#    mig8447     1.0.0      08/08/2018 - Created
#                                      - Added: get_real_script_directory.
#                                        and get_quoted_variable functions

# TODO: Put below variables within a namespace
#script_name='mig8447_commons.sh'
#script_human_readable_name='mig8447 Bash Commons'
#script_description='A Common Functions Library for Bash'
#script_version='1.2.0'

# TODO: Make exit codes match some shell guideline
# Exit Code Meanings
# 0 - Success
# 1 - Unrecoverable Error
# 2 - Recoverable Error

function get_real_script_directory {
    local exit_code=0

    # According to the Bash documentation, the ${BASH_SOURCE[$i]} is the name
    # of the file defining the current function and ${BASH_SOURCE[$i+1]} is
    # the name of the file calling the function, that's why we use
    # ${BASH_SOURCE[1]}

    local script_directory
    script_directory="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
    local real_script_path=''
    local real_script_directory=''

    if real_script_path="$( readlink -e "$script_directory"'/'"$( basename \
        "${BASH_SOURCE[1]}" )" )"
    then
        real_script_directory="$( dirname "$real_script_path" )"
    else
        real_script_directory="$script_directory"
    fi

    echo "$real_script_directory"

    return "$exit_code"
}

function add_path_to_path {
    local exit_code=0

    local path_to_add="$1"
    local prepend="${2:-false}"

    if [[ ! -e "$path_to_add" ]]; then
        echo 'WARNING: '"${FUNCNAME[0]}"': The passed path_to_add '\
"'$path_to_add'"' does not exist' >&2
        exit_code=2
    fi

    if [[ ':'"$PATH"':' != *':'"$path_to_add"':'* ]]; then
        if [[ "$prepend" == "false" ]]; then
            export PATH="$PATH"':'"$path_to_add"
        else
            export PATH="$path_to_add"':'"$PATH"
        fi
    else
        # shellcheck disable=SC2016
        echo 'WARNING: '"${FUNCNAME[0]}"': The passed path_to_add '\
"'$path_to_add'"' was part of the $PATH already' >&2
        exit_code=2
    fi

    return "$exit_code"
}

function append_path_to_path {
    add_path_to_path "$1"
    return "$?"
}
function prepend_path_to_path {
    add_path_to_path "$1" 'true'
    return "$?"
}

function get_quoted_variable {
    local exit_code=0

    local variable_name="$1"
    local export_variable="${2:-false}"

    if [[ -n "$variable_name" ]]; then
        if [[ "$export_variable" == "true" ]]; then
            echo -n 'export '
        fi
        echo "$( printf '%q' "$variable_name" )"'='"$( printf '%q' \
            "${!variable_name}" )"
    else
        echo 'ERROR: '"${FUNCNAME[0]}"': Passed variable_name '\
"'$variable_name'"' should not be empty' >&2
        exit_code=1
    fi

    return "$exit_code"
}

function get_alias_string {
    local result
    result="$( alias "$1"  | sed -re 's/^[^=]+?=//' )"
    eval 'echo '"$result"
}

export -f get_real_script_directory
export -f get_quoted_variable
export -f append_path_to_path
export -f prepend_path_to_path
export -f get_alias_string
