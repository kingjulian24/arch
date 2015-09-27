#!/bin/bash
CONFIG="$(pwd)/config"
USERNAME="nripoll"

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


# virtualbox guest utils conf
cat > /etc/modules-load.d/virtualbox.conf <<EOF
vboxguest
vboxsf
vboxvideo
EOF


# timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# hardware clock
hwclock --systohc --utc


# display/window Manager
abs community/dwm

pip install powerline-status

cp -f etc/X11/xdm/Xresources /etc/X11/xdm/Xresources

systemctl enable xdm

mkdir /usr/local/share/wallpapers

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF


# user
useradd -m -G wheel -s /bin/bash $USERNAME

su $USERNAME --command="mkdir -pv ~/.vim/colors ~/.vim/bundle ~/.local/share ~/.config/fontconfig/conf.d"
su $USERNAME --command="cp -f $CONFIG/vimrc ~/.vimrc"
su $USERNAME --command="cp -f $CONFIG/vim/colors/solarized.vim ~/.vim/colors/solarized.vim"
su $USERNAME --command="cp -f $CONFIG/xinitrc ~/.xinitrc"
su $USERNAME --command="cp -f $CONFIG/dircolors ~/.dircolors"
su $USERNAME --command="cp -f $CONFIG/Xresources ~/.Xresources"
su $USERNAME --command="cp -f $CONFIG/zshrc ~/.zshrc"
su $USERNAME --command="cp -fr /var/abs/community/dwm ~/dwm"
su $USERNAME --command="chmod 744 ~/.xinitrc"
su $USERNAME --command="git clone --depth=1 https://github.com/powerline/fonts.git ~/.local/share"
su $USERNAME --command="git clone --depth=1 https://github.com/VundleVim/vundle.vim.git ~/.vim/bundle/Vundle.vim"
su $USERNAME --command="git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
su $USERNAME --command="curl -L https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O ~/.local/share/fonts/PowerlineSymbols.otf"
su $USERNAME --command="curl -L https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf"
su $USERNAME --command="fc-cache -vf ~/.local/share/fonts"
su $USERNAME --command="chsh -s /bin/zsh"

# Initramfs
mkinitcpio -p linux
