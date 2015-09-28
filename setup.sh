#!/bin/bash
CURR_DIR=$(pwd)

			ARCH="https://github.com/nelsonripoll/arch.git"
    VUNDLE="https://github.com/VundleVim/vundle.vim.git"
   OHMYZSH="https://github.com/robbyrussell/oh-my-zsh.git"
  PKGQUERY="https://aur.archlinux.org/package_query.git"
    YAOURT="https://aur.archlinux.org/yaourt.git"

 SOLARIZED="~/arch/config/solarized/solarized_dark"
     VIMRC="~/arch/config/vim/vimrc"
     ZSHRC="~/arch/config/zshell/zshrc"
XRESOURCES="~/arch/config/x11/Xresources"
   XINITRC="~/arch/config/x11/xinitrc"
	     DWM="~/arch/config/dwm/config.h"

mkdir -pv ~/.vim/colors ~/.vim/bundle

git clone --depth=1 $ARCH ~/
git clone --depth=1 $VUNDLE ~/.vim/bundle/Vundle.vim
git clone --depth=1 $OHMYZSH ~/.oh-my-zsh

cp -f $XINITRC             ~/.xinitrc
cp -f $XRESOURCES          ~/.Xresources
cp -f $ZSHRC               ~/.zshrc
cp -f $VIMRC               ~/.vimrc
cp -f $SOLARIZED.vim       ~/.vim/colors/solarized.vim
cp -f $SOLARIZED.dircolors ~/.dircolors

cp -fr /var/abs/community/dwm ~/dwm
cd ~/dwm
makepkg
cp $DWM ~/dwm/config.h
makepkg -g >> PKGBUILD
makepkg -ef

cd $CURR_DIR
