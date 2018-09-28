#!/bin/bash

# If we are using iTerm then source the file first
# iTerm2 - Shell Integrations
# shellcheck disable=SC1090
test -e "${HOME}/.iterm2_shell_integration.bash" \
    && source "${HOME}/.iterm2_shell_integration.bash"

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

if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Enable forward history search
    # NOTE: This should be done in .bashrc.d/*history.sh but it only works if
    #       set here
    stty -ixon
fi

# Import common bash functions
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


