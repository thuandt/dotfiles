#!/bin/bash
# Filename: install.sh
# Last Modified: Mon 07 Jan 2013 01:07:00 AM ICT

DOTDIR="$(pwd)"

# install oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# init submodule
git submodule update --init --recursive

# Common
ln -sf "${DOTDIR}/dircolors/dircolors.256dark" ~/.dircolors
ln -sf "${DOTDIR}/exports" ~/.exports
ln -sf "${DOTDIR}/aliases" ~/.aliases
ln -sf "${DOTDIR}/functions" ~/.functions
ln -sf "${DOTDIR}/logger" ~/.logger

# bash
ln -sf "${DOTDIR}/bash/bashrc" ~/.bashrc
ln -sf "${DOTDIR}/bash/bash_logout" ~/.bash_logout
ln -sf "${DOTDIR}/bash/bash_profile" ~/.bash_profile

# zsh
ln -sf "${DOTDIR}/zsh/zlogout" ~/.zlogout
ln -sf "${DOTDIR}/zsh/zprofile" ~/.zprofile
ln -sf "${DOTDIR}/zsh/zshrc" ~/.zshrc
ln -sf "${DOTDIR}/zsh/zshenv" ~/.zshenv

# nvim
ln -sf "${DOTDIR}/nvim" ~/.config/nvim

# tmux/screen
ln -sf "${DOTDIR}/screen/screenrc" ~/.screenrc
ln -sf "${DOTDIR}/tmux/tmux.conf" ~/.tmux.conf
ln -sf "${DOTDIR}/tmux/colors/tmuxcolors-dark.conf" ~/.tmuxcolors.conf

