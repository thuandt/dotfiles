#!/bin/bash
# Filename: install.sh
# Last Modified: Mon 07 Jan 2013 01:07:00 AM ICT

DOTFILES=`pwd`

# install oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# common shell
ln -s "$DOTFILES/shell/aliases" ~/.shell_aliases
ln -s "$DOTFILES/shell/dir_colors" ~/.dir_colors
ln -s "$DOTFILES/shell/env" ~/.shell_env
ln -s "$DOTFILES/shell/functions" ~/.shell_functions

# bash
ln -s "$DOTFILES/bash/bashrc" ~/.bashrc
ln -s "$DOTFILES/bash/bash_logout" ~/.bash_logout
ln -s "$DOTFILES/bash/bash_profile" ~/.bash_profile

# zsh
ln -s "$DOTFILES/zsh/zlogout" ~/.zlogout
ln -s "$DOTFILES/zsh/zprofile" ~/.zprofile
cp "$DOTFILES/zsh/zshrc" ~/.zshrc
ln -s "$DOTFILES/zsh/zshenv" ~/.zshenv
mkdir -p ~/.oh-my-zsh/custom/themes
ln -s "$DOTFILES/zsh/mrtux.zsh-theme" ~/.oh-my-zsh/custom/themes

# install some config file
ln -s "$DOTFILES/screen/screenrc" ~/.screenrc
ln -s "$DOTFILES/tmux/tmux.conf" ~/.tmux.conf
