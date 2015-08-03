#!/usr/bin/bash

function read_input {
while true; do
	read -p "$1" value
	read -p "Is '$value' correct? (y/n): " confirm
	case $confirm in
		[Yy]) break;;
		[Nn]) ;;
		*) echo "Please answer 'y' or 'n'.";;
	esac
done

echo $value
}

current_dir=$(pwd)
cd /tmp

# Locale
export LANG=en_US.UTF-8
locale-gen $LANG
echo LANG=$LANG > /etc/locale.conf


# Timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# Hardware clock
hwclock --systohc --utc


# Hostname
hostname=$(read_input "Enter hostname: ")
echo $hostname > /etc/hostname


# User
username=$(read_input "Enter username: ")
useradd -m -G wheel -s /bin/bash $username
passwd $username


# Boot loader
gummiboot --path=/boot install

cat << EOT > /boot/loader/entries/arch.conf
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	root=/dev/sda2 rw
EOT

cat << EOT > /boot/loader/loader.conf
default  arch
timeout  3
EOT


# Ramdisk
mkinitcpio -p linux


cd $current_dir
echo "Remaining steps: add hostname to /etc/hosts and set root password."

