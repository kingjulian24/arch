#!/bin/bash

# boot loader
read -r -d '' ARCH <<'EOF'
title Arch Linux
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


# locale
cp /etc/locale.gen /etc/locale.gen.backup

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

locale-gen 


# timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# hardware clock
hwclock --systohc --utc


# hostname
echo "localhost" > /etc/hostname


# enable network
systemctl enable dhcpcd@enp0s3.service


# initramfs
mkinitcpio -p linux

sh -c "$(curl -fsSL https://raw.github.com/nelsonripoll/arch/master/tools/user_install.sh)"
