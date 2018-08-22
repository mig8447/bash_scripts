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
