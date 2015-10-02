#!/bin/bash
sgdisk -og /dev/sda

ENDSECTOR=`sgdisk -E /dev/sda`

sgdisk -n 1:2048:1050623        -c 1:"EFI"   -t 1:EF00 /dev/sda
sgdisk -n 2:1050623:$ENDSECTOR  -c 2:"ARCH"  -t 2:8300 /dev/sda

mkfs.vfat -F32 /dev/sda1
mkfs.ext4      /dev/sda2

mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

pacstrap /mnt base base-devel

genfstab -U -p /mnt >> /mnt/etc/fstab
