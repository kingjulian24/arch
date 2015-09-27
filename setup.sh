#!/bin/bash
CONFIG="$(pwd)/config"
USERNAME="nripoll"

# locale
cat > /etc/locale.gen <<EOF 
en_US.UTF-8 UTF-8
EOF

cat > /etc/locale.conf <<EOF 
LANG=en_US.UTF-8 EOF
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

cp -f $CONFIG/xdm/Xresources /etc/X11/xdm/Xresources

systemctl enable xdm

mkdir /usr/local/share/wallpapers

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF


# install patched fonts and config for powerline
POWERLINE="https://github.com/powerline"

git clone --depth=1 $POWERLINE/fonts.git /tmp/

mv /tmp/fonts/* /usr/share/fonts/

curl -L $POWERLINE/powerline/raw/develop/font/PowerlineSymbols.otf \
	   -O /usr/share/fonts/PowerlineSymbols.otf

curl -L $POWERLINE/powerline/raw/develop/font/10-powerline-symbols.conf \
	   -O /etc/fonts/conf.d/11-powerline-symbols.conf

fc-cache -vf /usr/share/fonts


# user setup
useradd -m -G wheel -s /bin/bash $USERNAME

su $USERNAME --c "cp -fr /var/abs/community/dwm ~/dwm"

su $USERNAME --c "mkdir -pv ~/.vim/colors ~/.vim/bundle" 

su $USERNAME --c "cp -f $CONFIG/x11/xinitrc ~/.xinitrc"
su $USERNAME --c "cp -f $CONFIG/x11/Xresources ~/.Xresources"

su $USERNAME --c "cp -f $CONFIG/zshrc ~/.zshrc"

su $USERNAME --c "cp -f $CONFIG/vim/vimrc ~/.vimrc"

su $USERNAME --c "cp -f $CONFIG/solarized/solarized_dark.vim ~/.vim/colors/solarized.vim"
su $USERNAME --c "cp -f $CONFIG/solarized/solarized_dark.dircolors ~/.dircolors"

su $USERNAME --c "git clone --depth=1 https://github.com/VundleVim/vundle.vim.git ~/.vim/bundle/Vundle.vim"
su $USERNAME --c "git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"

su $USERNAME --c "chsh -s /bin/zsh"


# initramfs
mkinitcpio -p linux
