#!/bin/bash
cd /tmp
git clone --depth=1 https://github.com/nelsonripoll/arch.git


# packages
read -r -d '' PKGS <<'EOF'
git zsh vim-python3 python-pip 
xorg-server xorg-xdm xorg-xinit 
qiv abs dmenu rxvt-unicode yajl
EOF

sudo sudo pacman -S --noconfirm $PKGS 


# yaourt
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
cd /tmp/package-query
makepkg -i --noconfirm

git clone https://aur.archlinux.org/yaourt.git /tmp/package-query
cd /tmp/yaourt
makepkg -i --noconfirm


#virtualbox guest utils
read -r -d '' VBOX <<'EOF'
vboxguest
vboxsf
vboxvideo
EOF

yaourt virtualbox-guest-utils

sudo modprobe -a vboxguest vboxsf vboxvideo

sudo echo $VBOX > /etc/modules-load.d/virtualbox.conf


# xdm
cp -f /tmp/arch/config/xdm/Xresources /etc/X11/xdm/Xresources

sudo systemctl enable xdm

sudo mkdir /usr/local/share/wallpapers

sudo cp /etc/X11/xdm/Xsetup_0 /etc/X11/xdm/Xsetup_0.backup

sudo sh -c 'echo "/usr/bin/qiv -zr /usr/local/share/wallpapers/*" > /etc/X11/xdm/Xsetup_0'


# DWM
sudo abs community/dwm


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


rm -rf /tmp/arch
cd ~
