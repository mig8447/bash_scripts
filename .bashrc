#!/bin/bash

_os_name="$( uname -s )"
export _os_name

function _is_interactive_shell(){
    local exit_code=0

    [[ "$-" =~ "i" && -t 0 && -t 1 && -t 2 ]]        
    exit_code="$?"

    return "$exit_code"
}

_is_interactive_shell
export _is_interactive_shell="$?"

# Enable these setings only if the terminal is interactive
if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Enable forward history search
    # NOTE: This setting should be in the .bashrc.d/*history.sh file
    #       but it only works if called directly from here
    stty -ixon
fi

# Import common Bash functions
# shellcheck disable=SC1090
source "$HOME"'/lib/mig8447_commons.sh'

# Configure the PATH
append_path_to_path "$HOME/bin"

# Import all of the non-executable *.sh files in $HOME/.bashrc.d
while read -r file; do
    # shellcheck disable=SC1090
    source "$file"
done < <(
        case "$_os_name" in
            ( Linux )
                find -L "$HOME"'/.bashrc.d' -maxdepth 1 \
                    -name '*.sh' -type f \
                    -not \( -executable \) \
                | sort -n
                ;;
            ( Darwin )
                find -L "$HOME"'/.bashrc.d' -maxdepth 1 \
                    -name '*.sh' -type f \
                | sort -n
                ;;
        esac
    )

# If we are using iTerm then source the file first
# iTerm 2 - Shell Integrations
# iTerm 2 Client Check based on https://gist.github.com/joerohde/b7a07db9ff9d1641bd3c7c2abbe2828d 
# shellcheck disable=SC1090
{ 
    "$HOME"'/lib/isiterm2.sh' \
        && test -e "${HOME}/.iterm2_shell_integration.bash" \
        && source "${HOME}/.iterm2_shell_integration.bash";
} || ( exit 0 )

