#!/bin/bash

# System settings
export LC_CTYPE='en_US.utf-8'

# Intractive shell only settings
if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Default Text Editor
    export EDITOR=vim

    case "$_os_name" in
        ( Linux )
            shopt -s direxpand
            ;;
    esac
    
    # Expand variables to their contents when tabbing
    shopt -s cdable_vars
fi

