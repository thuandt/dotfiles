#!/bin/bash
# install.sh
# Last Modified: Sun 06 Jan 2013 02:45:16 AM ICT

cp bash/bashrc ~/.bashrc
mkdir -p ~/.bin && cp bin/* ~/.bin
cp screen/screenrc ~/.screenrc
cp shell/aliases ~/.shell_aliases
cp shell/dir_colors ~/.dir_colors
cp shell/env ~/.shell_env
cp shell/functions ~/.shell_functions
cp tmux/tmux.conf ~/.tmux.conf
cp zsh/zlogout ~/.zlogout
cp zsh/zprofile ~/.zprofile
cp zsh/zshrc ~/.zshrc
