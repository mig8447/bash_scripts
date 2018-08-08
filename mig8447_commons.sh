#!/bin/bash

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

    local script_directory="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"
    local real_script_path=''
    local real_script_directory=''

    if real_script_path="$( readlink -e "$script_directory/$( basename "${BASH_SOURCE[1]}" )" )"; then
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
        echo 'WARNING: '"${FUNCNAME[0]}"': The passed path_to_add ($1) does not exist' >&2
        exit_code=2
    fi

    if [[ ':'"$PATH"':' != *':'"$path_to_add"':'* ]]; then
        if [[ "$prepend" == "false" ]]; then
            export PATH="$PATH"':'"$path_to_add"
        else
            export PATH="$path_to_add"':'"$PATH"
        fi
    else
        echo 'WARNING: '"${FUNCNAME[0]}"': The passed path_to_add ($1) was part of the $PATH already' >&2
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
        echo "$( printf '%q' "$variable_name" )"'='"$( printf '%q' "${!variable_name}" )"
    else
        echo 'ERROR: quote_variable: Variable_name ($1) should not be empty' >&2
        exit_code=1
    fi

    return "$exit_code"
}

export -f get_real_script_directory
export -f get_quoted_variable
export -f append_path_to_path
export -f prepend_path_to_path
