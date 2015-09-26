#!/bin/bash
mkdir -pv ~/.vim/colors ~/.vim/bundle ~/.local/share/fonts ~/.config/fontconfig/conf.d

cp -f dotfiles/dircolors ~/.dircolors
cp -f dotfiles/Xresources ~/.Xresources
cp -f dotfiles/vimrc ~/.vimrc
cp -f dotfiles/vim/colors/solarized.vim ~/.vim/colors/solarized.vim
cp -f dotfiles/zshrc ~/.zshrc
cp -f dotfiles/local/share/fonts/DejaVuSansMono-Powerline.ttf ~/.local/share/fonts/DejaVuSansMono-Powerline.ttf
cp -f /etc/X11/xinit/xinitrc ~/.xinitrc
cp -fr /var/abs/community/dwm ~/dwm

chmod 744 ~/.xinitrc

git clone --depth=1 https://github.com/VundleVim/vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
