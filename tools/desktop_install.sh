#!/bin/bash
cd /tmp

           GITHUB="https://github.com"
              AUR="https://aur.archlinux.org"
             ARCH="$GITHUB/nelsonripoll/arch.git"
           VUNDLE="$GITHUB/VundleVim/vundle.vim.git"
          OHMYZSH="$GITHUB/robbyrussell/oh-my-zsh.git"
  POWERLINE_FONTS="$GITHUB/powerline/fonts.git"
POWERLINE_SYMBOLS="$GITHUB/powerline/powerline/raw/develop/font/PowerlineSymbols.otf"
   POWERLINE_CONF="$GITHUB/powerline/powerline/raw/develop/font/10-powerline-symbols.conf"
    PACKAGE_QUERY="$AUR/package-query.git"
           YAOURT="$AUR/yaourt.git"

read -r -d '' PACKAGES <<EOF
git zsh vim-python3 python-pip rxvt-unicode  
xorg-server xorg-xdm xorg-xinit xorg-xdpyinfo
qiv abs dmenu yajl
EOF

read -r -d '' XDM_SETUP <<EOF
cp -f /tmp/arch/config/xdm/Xresources /etc/X11/xdm/Xresources
systemctl enable xdm
mkdir /usr/local/share/wallpapers
cp /etc/X11/xdm/Xsetup_0 /etc/X11/xdm/Xsetup_0.backup
sh -c 'echo "/usr/bin/qiv -zr /usr/local/share/wallpapers/*" > /etc/X11/xdm/Xsetup_0'
EOF

read -r -d '' VB_SETUP <<EOF
modprobe -a vboxguest vboxsf vboxvideo

cat > /etc/modules-load.d/virtualbox.conf <<HEREDOC
vboxguest
vboxsf
vboxvideo
HEREDOC
EOF


read -r -d '' POWERLINE_SETUP <<EOF
pip install powerline-status
mv /tmp/powerlinesymbols.otf /usr/share/fonts/powerlinesymbols.otf
mv /tmp/11-powerline-symbols.conf /etc/fonts/conf.d/11-powerline-symbols.conf
mv /tmp/fonts/* /usr/share/fonts/
EOF


# packages
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm $PACKAGES 

git clone --depth=1 $ARCH            /tmp/arch
git clone --depth=1 $PACKAGE_QUERY   /tmp/package-query
git clone --depth=1 $YAOURT          /tmp/yaourt
git clone --depth=1 $VUNDLE          /tmp/Vundle.vim
git clone --depth=1 $OHMYZSH         /tmp/oh-my-zsh
git clone --depth=1 $POWERLINE_FONTS /tmp/fonts

curl -L $powerline_symbols -o   /tmp/powerlinesymbols.otf
curl -L $powerline_conf -o      /tmp/11-powerline-symbols.conf


# yaourt & vb guest utils
cd /tmp/package-query
makepkg -i --noconfirm

cd /tmp/yaourt
makepkg -i --noconfirm

yaourt virtualbox-guest-utils

sudo sh -c "$VB_SETUP"


# xdm
sudo sh -c "$XDM_SETUP"


# dwm
sudo abs community/dwm
cp -fr /var/abs/community/dwm ~/dwm


# powerline & fonts
sudo sh -c "$POWERLINE_SETUP"

fc-cache -vf /usr/share/fonts


# home & dwm setup
mkdir -pv ~/.vim/colors ~/.vim/bundle

mv -f /tmp/Vundle.vim                                       ~/.vim/bundle/Vundle.vim
mv -f /tmp/oh-my-zsh                                        ~/.oh-my-zsh
mv -f /tmp/arch/config/x11/xinitrc                          ~/.xinitrc
mv -f /tmp/arch/config/x11/Xresources                       ~/.Xresources
mv -f /tmp/arch/config/solarized/solarized_dark.dir_colors  ~/.dir_colors
mv -f /tmp/arch/config/zshell/zshrc                         ~/.zshrc
mv -f /tmp/arch/config/vim/vimrc                            ~/.vimrc
mv -f /tmp/arch/config/solarized/solarized_dark.vim         ~/.vim/colors/solarized.vim

cd ~/dwm
makepkg -i --noconfirm
mv -f /tmp/arch/config/dwm/config.h ~/dwm/config.h
makepkg -g >> PKGBUILD
makepkg -ief --noconfirm


# go home
cd ~
