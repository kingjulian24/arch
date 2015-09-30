#!/bin/bash
pacman -S --noconfirm git zsh vim-python3 python-pip xorg-server xorg-xdm xorg-xinit qiv abs dmenu rxvt-unicode yajl


# locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "localhost" > /etc/hostname

locale-gen 


# timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# hardware clock
hwclock --systohc --utc


# boot loader
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


# powerline and patched fonts
pip install powerline-status

git clone --depth=1 https://github.com/powerline/fonts.git /tmp/fonts

mv /tmp/fonts/* /usr/share/fonts/

curl -L https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -o /usr/share/fonts/PowerlineSymbols.otf

curl -L https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -o /etc/fonts/conf.d/11-powerline-symbols.conf

fc-cache -vf /usr/share/fonts
