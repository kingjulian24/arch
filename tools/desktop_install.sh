#!/bin/bash
cd /tmp
git clone --depth=1 https://github.com/nelsonripoll/arch.git
ARCH=/tmp/arch/config

# packages
read -r -d '' PKGS <<'EOF'
git zsh vim-python3 python-pip 
xorg-server xorg-xdm xorg-xinit 
qiv abs dmenu rxvt-unicode yajl
EOF

sudo pacman -S --noconfirm $PKGS 


#virtualbox guest utils
read -r -d '' VBOX <<'EOF'
vboxguest
vboxsf
vboxvideo
EOF

yaourt virtualbox-guest-utils

modprobe -a vboxguest vboxsf vboxvideo

echo $VBOX > /etc/modules-load.d/virtualbox.conf


# powerline
cd /tmp 

POWERLINE_FONTS="https://github.com/powerline/fonts.git"
POWERLINE_SYMBOLS="https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf"
POWERLINE_CONF="https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf"

sudo pip install powerline-status

sudo curl -L $POWERLINE_SYMBOLS -o /usr/share/fonts/PowerlineSymbols.otf
sudo curl -L $POWERLINE_CONF -o /etc/fonts/conf.d/11-powerline-symbols.conf

git clone --depth=1 $POWERLINE_FONTS /tmp/fonts
mv /tmp/fonts/* /usr/share/fonts/

fc-cache -vf /usr/share/fonts


# Xorg
read -r -d '' XDM <<'EOF'
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF

cp -f $ARCH/xdm/Xresources /etc/X11/xdm/Xresources

systemctl enable xdm

mkdir /usr/local/share/wallpapers

cp /etc/X11/xdm/Xsetup_0 /etc/X11/xdm/Xsetup_0.backup

echo $XDM > /etc/X11/xdm/Xsetup_0


# DWM
abs community/dwm


rm -rf /tmp/arch
cd ~
