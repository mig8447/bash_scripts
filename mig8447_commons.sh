#!/bin/bash

function get_real_script_directory {
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
}

function get_quoted_variable {
    local variable_name="$1"
    local export_variable="${2:-false}"

    local exit_code=0

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
