#!/bin/bash
pacman -S --noconfirm git yajl

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


# yaourt
cd /tmp

read -r -d '' SUDOERS <<'EOF'
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

read -r -d '' CMNDS <<'EOF'
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
cd /tmp/package-query
makepkg -i --noconfirm

git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
cd /tmp/yaourt
makepkg -i --noconfirm
EOF

echo $SUDOERS >> /etc/sudoers

cp /etc/sudoers /etc/sudoers.backup

useradd -m -G wheel -s /bin/bash arch-user

su arch-user -c "$CMNDS"

userdel arch-user

mv /etc/sudoers.backup /etc/sudoers


# initramfs
mkinitcpio -p linux

cd ~
