#!/bin/bash -x

exit_code=0

script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if real_script_path="$( readlink -e "$script_directory/$( basename \
    "${BASH_SOURCE[0]}" )" )"
then
    real_script_directory="$( dirname "$real_script_path" )"
else
    real_script_directory="$script_directory"
fi

#Create backups of the original files if any
if [ -s "$HOME""/.bashrc" ]; then 
    cp "$HOME"/.bashrc "$HOME"/.bashrc.scriptbkup
    echo "Backup created for .bashrc file"
fi
if [ -s "$HOME""/.bash_profile" ]; then 
    cp "$HOME"/.bash_profile "$HOME"/.bash_profile.scriptbkup
    echo "Backup created for .bash_profile file"
fi
if [ -s "$HOME""/.vimrc" ]; then
    cp "$HOME"/.vimrc "$HOME"/.vimrc
    echo "Backup created for .vimrc file"
fi

if [ -d "$HOME""/.vim" ]; then
    cp -rL "$HOME"/.vim "$HOME"/.vim_bkup/
    echo "Backup created for .vim/ dir"
fi

if [ ! -d "$HOME""/lib" ]; then
    mkdir -p "$HOME"'/lib'
fi

#Create symlinks 
ln -fns "$real_script_directory"'/lib/mig8447_commons.sh' \
    "$HOME"'/lib/mig8447_commons.sh'
ln -fns "$real_script_directory"'/lib/isiterm2.sh' \
    "$HOME"'/lib/isiterm2.sh'
ln -fns "$real_script_directory"'/.bashrc' "$HOME"'/.bashrc'
ln -fns "$real_script_directory"'/.bashrc_nohistory' "$HOME"'/.bashrc_nohistory'
ln -fns "$real_script_directory"'/.bashrc.d/' "$HOME"'/.bashrc.d'
ln -fns "$real_script_directory"'/.bash_profile' "$HOME"'/.bash_profile'
ln -fns "$real_script_directory"'/.vimrc' "$HOME"'/.vimrc'
ln -fns "$real_script_directory"'/.vim/' "$HOME"'/.vim'
ln -fns "$real_script_directory"'/.inputrc' "$HOME"'/.inputrc'
ln -fns "$real_script_directory"'/.jq' "$HOME"'/.jq'

exit "$exit_code"
