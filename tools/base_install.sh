#!/bin/bash

# variables
POWERLINE_FONTS="https://github.com/powerline/fonts.git"
POWERLINE_SYMBOLS="https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf"
POWERLINE_CONF="https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf"

read -r CMNDS <<EOF
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -i --noconfirm

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -i --noconfirm
EOF

read -r PKGS <<EOF
git zsh vim-python3 python-pip 
xorg-server xorg-xdm xorg-xinit 
qiv abs dmenu rxvt-unicode yajl
EOF

read -r ARCH <<EOF
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF

read -r BOOT <<EOF
default arch
timeout 3
EOF


# packages
pacman -S --noconfirm $PKGS 


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

echo "$ARCH" > /boot/loader/entries/arch.conf 
echo "$BOOT" > /boot/loader/loader.conf


# powerline and patched fonts
pip install powerline-status

curl -L $POWERLINE_SYMBOLS -o /usr/share/fonts/PowerlineSymbols.otf
curl -L $POWERLINE_CONF -o /etc/fonts/conf.d/11-powerline-symbols.conf

git clone --depth=1 $POWERLINE_FONTS /tmp/fonts
mv /tmp/fonts/* /usr/share/fonts/

fc-cache -vf /usr/share/fonts


# enable network
systemctl enable dhcpcd@enp0s3.service


# create user for non-root tasks
cp /etc/sudoers /etc/sudoers.bkp

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

useradd -m -G wheel -s /bin/bash arch-user

su arch-user -c "$CMNDS"

userdel arch-user

mv /etc/sudoers.bkp /etc/sudoers
