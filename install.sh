#!/bin/bash
# Filename: install.sh
# Last Modified: Mon 07 Jan 2013 01:07:00 AM ICT

cp bash/bashrc ~/.bashrc
cp bash/bash_logout ~/.bash_logout
cp bash/bash_profile ~/.bash_profile
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
