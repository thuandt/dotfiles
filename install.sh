#!/bin/bash
# Filename: install.sh
# Last Modified: Mon 07 Jan 2013 01:07:00 AM ICT

DOTFILES=`pwd`

# install oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# common shell
cp "$DOTFILES/shell/aliases" ~/.shell_aliases
cp "$DOTFILES/shell/dircolors/dircolors.256dark" ~/.dircolors.256dark
cp "$DOTFILES/shell/env" ~/.shell_env
cp "$DOTFILES/shell/functions" ~/.shell_functions

# bash
cp "$DOTFILES/bash/bashrc" ~/.bashrc
cp "$DOTFILES/bash/bash_logout" ~/.bash_logout
cp "$DOTFILES/bash/bash_profile" ~/.bash_profile

# zsh
cp "$DOTFILES/zsh/zlogout" ~/.zlogout
cp "$DOTFILES/zsh/zprofile" ~/.zprofile
cp "$DOTFILES/zsh/zshrc" ~/.zshrc
cp "$DOTFILES/zsh/zshenv" ~/.zshenv
mkdir -p ~/.oh-my-zsh/custom/themes
cp "$DOTFILES/zsh/mrtux.zsh-theme" ~/.oh-my-zsh/custom/themes

# vim
cp -R $DOTFILES/vim ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc

# install some config file
cp "$DOTFILES/screen/screenrc" ~/.screenrc
cp "$DOTFILES/tmux/tmux.conf" ~/.tmux.conf

