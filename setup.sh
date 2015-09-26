#!/bin/bash
DOTFILES="$(pwd)/dotfiles"

# locale
cat > /etc/locale.gen <<EOF 
en_US.UTF-8 UTF-8
EOF

cat > /etc/locale.conf <<EOF 
LANG=en_US.UTF-8
EOF

locale-gen


# /boot
bootctl install

cat > /boot/loader/entries/arch.conf <<EOF 
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF

cat > /boot/loader/loader.conf <<EOF 
default arch
timeout 3
EOF


# timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# hardware clock
hwclock --systohc --utc


# display/window Manager
pacman --noconfirm -S xorg-server xorg-xdm xorg-xinit qiv abs dmenu rxvt-unicode vim-python3 python-pip yajl

abs community/dwm

pip install powerline-status

cp -f etc/X11/xdm/Xresources /etc/X11/xdm/Xresources

mkdir /usr/local/share/wallpapers

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF


# user
useradd -m -G wheel -s /bin/bash nripoll

su nripoll --command="mkdir -pv ~/.vim/colors ~/.vim/bundle ~/.local/share/fonts ~/.config/fontconfig/conf.d"
su nripoll --command="cp -f $DOTFILES/vimrc ~/.vimrc"
su nripoll --command="cp -f $DOTFILES/vim/colors/solarized.vim ~/.vim/colors/solarized.vim"
su nripoll --command="cp -f $DOTFILES/local/share/fonts/DejaVuSansMono-Powerline.ttf ~/.local/share/fonts/DejaVuSansMono-Powerline.ttf"
su nripoll --command="cp -f $DOTFILES/xinitrc ~/.xinitrc"
su nripoll --command="cp -f $DOTFILES/dircolors ~/.dircolors"
su nripoll --command="cp -f $DOTFILES/Xresources ~/.Xresources"
su nripoll --command="cp -f $DOTFILES/zshrc ~/.zshrc"
su nripoll --command="chmod 744 ~/.xinitrc"
su nripoll --command="fc-cache -vf ~/.local/share/fonts"
su nripoll --command="git clone --depth=1 https://github.com/VundleVim/vundle.vim.git ~/.vim/bundle/Vundle.vim"
su nripoll --command="git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
su nripoll --command="chsh -s /bin/zsh"

# Initramfs
mkinitcpio -p linux
