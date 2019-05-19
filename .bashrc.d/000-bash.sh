#!/bin/bash

# System settings
export LC_CTYPE='en_US.utf-8'

# Intractive shell only settings
if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Default Text Editor
    if command -v vim &>/dev/null; then
        export EDITOR=vim
    else
        export EDITOR=vi
        alias vim='vi'
    fi

    case "$_os_name" in
        ( Linux )
            shopt -s direxpand
            # Allow Recursive Globbing
            shopt -s globstar
            ;;
        ( Darwin )
            # Expand variables to their contents when tabbing
            shopt -s cdable_vars
            ;;
    esac

    shopt -s dotglob
fi

