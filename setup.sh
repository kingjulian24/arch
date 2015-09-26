#!/bin/bash

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
pacman --noconfirm -S xorg-server xorg-xdm xorg-xinit qiv abs dmenu rxvt-unicode vim-python3 python-pip

abs community/dwm

pip install powerline-status

cp -f etc/X11/xdm/Xresources /etc/X11/xdm/Xresources

mkdir /usr/local/share/wallpapers

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF


# user
useradd -m -G wheel -s /bin/zsh nripoll

su nripoll --command="sh user.sh"


# Initramfs
mkinitcpio -p linux
