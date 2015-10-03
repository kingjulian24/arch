#!/bin/bash

# boot loader
read -r -d '' ARCH <<'EOF'
title Waffles
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF

read -r -d '' BOOT <<'EOF'
default arch
timeout 3
EOF

bootctl install

echo "$ARCH" > /boot/loader/entries/arch.conf 
echo "$BOOT" > /boot/loader/loader.conf


# enable network
systemctl enable dhcpcd@enp0s3.service


# locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "localhost" > /etc/hostname

locale-gen 


# timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# hardware clock
hwclock --systohc --utc


# create user for non-root tasks
cd /tmp

read -r -d '' CMNDS <<'EOF'
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -i --noconfirm

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -i --noconfirm
EOF

cp /etc/sudoers /etc/sudoers.bkp

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

useradd -m -G wheel -s /bin/bash arch-user

su arch-user -c "$CMNDS"

userdel arch-user

mv /etc/sudoers.bkp /etc/sudoers


# initramfs
mkinitcpio -p linux

cd ~
