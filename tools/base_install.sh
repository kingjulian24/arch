#!/bin/bash

# clear hard disk
sgdisk -og /dev/sda

# boot partition
FIRST_SECTOR=$(sgdisk -F /dev/sda)

sgdisk  -n 1:$FIRST_SECTOR:+512M  -c 1:"EFI"  -t 1:EF00 /dev/sda


# root partition
FIRST_SECTOR=$(sgdisk -F /dev/sda)
  END_SECTOR=$(sgdisk -E /dev/sda)

sgdisk  -n 2:$FIRST_SECTOR:$END_SECTOR  -c 2:"ARCH"  -t 2:8300 /dev/sda


# format partitions
mkfs.vfat -F32 /dev/sda1
mkfs.ext4      /dev/sda2


# mount partitions
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot


# install linux
pacstrap /mnt base base-devel


# generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


# post install
arch-chroot /mnt /bin/bash -c '"sh -c $(https://raw.github.com/nelsonripoll/arch/master/tools/post_install.sh)"'
