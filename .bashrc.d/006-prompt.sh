#!/bin/bash

# REQUIRES: mig8447_commons.sh

# Prompt Configuration 
function _set_prompt {
    local previous_command_exit_code="$?"
    local exit_code=0

    # Prompt string: <START_BOLD_TEXT>[<USER>@<SHORT_HOSTNAME>
    PS1='\[\033[1m\][\u@\h '

    # Prompt + <START_CYAN_TEXT><CWD><RESET_ATTRIBUTES><START_BOLD_TEXT>](
    PS1="$PS1"'\[\033[36m\]\W\[\033[0m\]\[\033[1m\]]('

    if [[ "$previous_command_exit_code" -eq 0 ]]; then
        # Prompt + <START_GREEN_TEXT>
        PS1="$PS1"'\[\033[32m\]'
    else
        # Prompt + <START_RED_TEXT>
        PS1="$PS1"'\[\033[91m\]'
    fi

    # Prompt + <LAST_EXIT_CODE><RESET_ATTRIBUTES><START_BOLD_TEXT>)$
    # <RESET_BOLD_TEXT>
    PS1="$PS1""$previous_command_exit_code"\
'\[\033[0m\]\[\033[1m\])\$\[\033[22m\] '

    return "$exit_code"
}

# shellcheck disable=SC2154
if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Set the prompt and dump every command to history immediately
    export PROMPT_COMMAND="_set_prompt; history -a;"
fi
