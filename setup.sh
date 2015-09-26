#!/bin/bash
pacman --noconfirm -S xorg-server xorg-xdm xorg-xinit qiv abs demnu rxvt-unicode zsh vim-python3 python-pip

bootctl install

abs community/dwm

pip install powerline-status

cat > /etc/locale.gen <<EOF 
en_US.UTF-8 UTF-8
EOF

cat > /etc/locale.conf <<EOF 
LANG=en_US.UTF-8
EOF

cat > /boot/loader/loader.conf <<EOF 
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	root=/dev/sdxY rw
EOF

cat > /boot/loader/loader.conf <<EOF 
default	arch
timeout	3
EOF

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF

locale-gen

ln -s /usr/share/zoneinfo/US/Central /etc/localtime

hwclock --systohc --utc


cp -f etc/X11/xdm/Xresources /etc/X11/xdm/Xresources

echo "creating user 'nripoll'"
useradd -m -G wheel -s /bin/zsh nripoll

echo "enter password for user 'nripoll'\n"
passwd nripoll

echo "switching to user 'nripoll'\n"
su nripoll

mkdir -pv ~/.vim/colors ~/.vim/bundle ~/.local/share/fonts ~/.config/fontconfig/conf.d

cp -f dotfiles/dircolors ~/.dircolors
cp -f dotfiles/Xresources ~/.Xresources
cp -f dotfiles/vimrc ~/.vimrc
cp -f dotfiles/zshrc ~/.zshrc
cp -f dotfiles/local/share/fonts/DejaVuSansMono-Powerline.ttf ~/.local/share/fonts/DejaVuSansMono-Powerline.ttf
cp -f /etc/X11/xinit/xinitrc ~/.xinitrc
cp -fr /var/abs/community/dwm ~/dwm

chmod 744 ~/.xinitrc

git clone --depth=1 https://github.com/VundleVim/vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

exit

mkinitcpio -p linux
