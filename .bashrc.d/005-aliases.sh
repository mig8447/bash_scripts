#!/bin/bash

# Only set these aliases if shell is interactive
# shellcheck disable=SC2154
if [[ "$_is_interactive_shell" -eq 0 ]]; then
    # Allow alias expansion
    shopt -s expand_aliases

    # Date aliases
    alias current_datetime='date +"%Y%m%d_%H%M%S"'
    alias current_datetime_mx='TZ='"'"'America/Mexico_City'"'"' '\
"current_datetime"

    # General Utilities Aliases
    alias mv='mv -v'
    alias cp='cp -v'
    case "${_os_name:-Linux}" in
        Linux )
            # List all files except for .. and ., append a / to the files that
            # are directories and enable coloring
            alias ls='ls -Ap --color=auto'
            # Use the ls alias above but group directories first
            alias lf='ls --group-directories-first'
            # Use the lf alias above but display only one file per line
            alias lf1='lf -1'
            ;;
        Darwin )
            # List all files except for .. and ., append a / to the files that
            # are directories and enable coloring
            alias ls='ls -ApG'
            ;;
    esac
    # Same as above but display every file in a single line
    alias ls1='ls -1'
    # Use the ls alias above but list all attributes
    alias ll='ls -l'
    # List the contents of a tar file (This also works for compressed archives
    # e.g .tar.gz files)
    alias lstar='tar -tvf'
    # Extract the contents of a tar file (Works with compressed tar archives)
    alias untar='tar -xvf'
    # Replace the contents of a file in paste mode
    alias vimreplace='vim -c '"'"'1,$d'"'"' -c '"'"'set noexpandtab'"'"' -c '\
"'"'set paste'"'"' -c '"'"'startinsert'"'"
    # Edit the .bashrc file
    alias vimrc='vim "$HOME"'"'"'/.bashrc'"'"
    # Edit the .bashrc.d directory
    alias vimrcd='vim "$HOME"'"'"'/.bashrc.d'"'"
    # Interactive alias for rm
    alias rm='confirm_rm'

    alias md5sum='md5'

    # Git aliases
    # Git Fast Push
    alias gitfp='git add . && { read -p '"'"'Commit Message: '"'"' -a '\
'_git_commit_message && git commit -m "${_git_commit_message[*]}"; '\
'unset _git_commit_message; } && git push'
fi
