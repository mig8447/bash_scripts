#!/bin/bash

function confirm_rm {
    local exit_code=0

    # shellcheck disable=SC2154
    if [[ "$_is_interactive_shell" -eq 0 ]]; then
        read -rp 'Are you sure you want to use the "rm" command? (Type "Yes" '\
'to confirm or anything else to exit): ' \
            && {
                {
                    [[ "$REPLY" =~ ^[Yy]$ ]] \
                    && echo 'ERROR: Please type "Yes"' >&2 \
                    && ( exit 1 );
                } \
                || {
                    [[ "$REPLY" == 'Yes' ]] \
                    && command rm -v "$@";
                };
            }
        exit_code="$?"
    else
        rm "$@"
        exit_code="$?"
    fi

    return "$exit_code"
}
function vimrcd(){
    local exit_code=0

    local bashrc_directory="$HOME"'/.bashrc.d/'
    local file_name_pattern="$1"
    local file_name=""

    if [[ ! -z "$file_name_pattern" ]]; then
        file_name_pattern='*'"$file_name_pattern"'*'
        if file_name="$( set -o pipefail; find "$bashrc_directory" -iname "$file_name_pattern" -type f 2>/dev/null | sort -u | head -n 1 )"; then
            if [[ ! -z "$file_name" ]]; then
                vim "$file_name"
                exit_code="$?"
            else
                echo 'ERROR: vimrcd: Could not find a match for pattern "'"$file_name_pattern"'" in "'"$bashrc_directory"'"'
                exit_code=1
            fi
        else
            echo 'ERROR: vimrcd: An error occurred while searching for pattern "'"$file_name_pattern"'" in "'"$bashrc_directory"'"'
            exit_code=1
        fi
    else
        # Edit the .bashrc.d directory
        vim -c 'e '"$bashrc_directory"
        exit_code="$?"
    fi

    return "$exit_code"
}
