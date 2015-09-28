# Arch Linux Post Installation

Log in as the created user. Install remaining dependencies and clone this project.

```
sudo pacman -S --noconfirm git zsh vim-python3 python-pip xorg-server xorg-xdm xorg-xinit qiv abs dmenu rxvt-unicode yajl
git clone https://github.com/nelsonripoll/arch.git /tmp/
```

## Yaourt

```
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg
sudo pacman -U --noconfirm package-query*.pkg.tar.xz

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg
sudo pacman -U --noconfirm yaourt*.pkg.tar.xz
```

## VirtualBox Guest Utils

```
yaourt virtualbox-guest-utils

sudo modprobe -a vboxguest vboxsf vboxvideo
```

Open _/etc/modules-load.d/virtualbox.conf_ and add the following:

```
vboxguest
vboxsf
vboxvideo
```

## Powerline & Fonts

```
sudo pip install powerline-status

git clone --depth=1 $POWERLINE/fonts.git /tmp/

mv /tmp/fonts/* /usr/share/fonts/

curl -L https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
	   -O /usr/share/fonts/PowerlineSymbols.otf

sudo curl -L https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
	        -O /etc/fonts/conf.d/11-powerline-symbols.conf

fc-cache -vf /usr/share/fonts
```

## XDM Display Manager

```
cp -f arch/config/xdm/Xresources /etc/X11/xdm/Xresources

systemctl enable xdm

mkdir /usr/local/share/wallpapers
```

Open _/etc/X11/xdm/Xsetup_0_ and make sure this is the only thing in there:

```
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
```

## DWM

```
sudo abs community/dwm
```
