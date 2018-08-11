#!/bin/bash

# History Setup

# Append to the history file instead of overwriting it
shopt -s histappend
# Unlimited History
export HISTSIZE=''
export HISTFILESIZE=''
# Set History Timestamps
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S %Z '
export HISTIGNORE=''
export HISTCONTROL='ignoreboth:erasedups'
