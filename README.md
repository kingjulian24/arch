# Arch Linux Guest In VirtualBox
[new]: ./img/vb/new  "NEW VIRTUAL"
[os]:  ./img/vb/os   "ARCH GUEST"
[mem]: ./img/vb/mem  "ALLOCATE MEMORY"
[hd1]: ./img/vb/hd1  "NEW HARD DISK"
[hd2]: ./img/vb/hd2  "HARD DISK TYPE"
[hd3]: ./img/vb/hd3  "HARD DISK STORAGE TYPE"
[hd4]: ./img/vb/hd4  "HARD DISK LOCATION AND SIZE"
[efi]: ./img/vb/efi  "ENABLE EFI"
[iso]: ./img/vb/iso  "LOAD ARCH ISO"

## Getting Started
Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Arch Linux](https://www.archlinux.org/download/).

## VirtualBox
![Create a new virtual][new]
![Name is arch, type is Linux, version is Arch Linux (64-bit)][os]
![Allocate memorty for virtual][mem]
![Create or select existing hard disk if needed][hd1]
![Select hard disk type if new][hd2]
![Set storage type: dynamic or fixed][hd3]
![Name virtual file and set max size][hd4]
![Enable efi in the virtual settings under system tab][efi]
![Start virtual and load iso][iso]

## Arch Linux
Partition the */dev/sda* disk:

    cgdisk /dev/sda

First, the */boot* partition. We will be booting with UEFI, select **NEW** and enter the following:
+ default sector
+ size = 512M
+ hex code = ef00
+ partition name = BOOT

Next is the */* partition, select **NEW** over the free partition:
+ default sector
+ default size
+ default hex code
+ partition name = ARCH

*Note: partition names do not have to be 'BOOT' or 'ARCH'*

Format the EFI and ARCH partition:

    mkfs.vfat -F32 /dev/sda1
    mkfs.ext4 /dev/sda2

Mount partitions:

    mount /dev/sda2 /mnt
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot

Edit the mirror list (optional):

    nano /etc/pacman.d/mirrorlist

Install the base system and generate the fstab:

    pacstrap -i /mnt base base-devel git zsh
    genfstab -U -p /mnt >> /mnt/etc/fstab

Chroot into */mnt*, clone this project, and run **setup.sh**:

    arch-chroot /mnt /bin/bash
    git clone https://github.com/nelsonripoll/arch.git
    cd arch
    sh setup.sh

VirtualBox looks for */boot/EFI/BOOT/BOOTX64.EFI* when booting with UEFI. If that doesn't exist, move/rename the boot loader until it matches.

Edit the sudoers file to give the wheel root access:

    visudo

Set passwords for root and the created user(s):
    passwd
    passwd username
    
Enable wired network where interface can be retrieved from **ip link**:

    ip link
    systemctl enable dhcpcd@interface.service

Enable the xdm system service:

    sudo systemctl enable xdm

Add wallpapers to */usr/local/share/wallpapers* (optional).

Finish dwm setup as non-root user. 

    cd ~/dwm
    makepkg -i

Make any custom changes to *~/dwm/config.h* and rebuild.

    makepkg -g >> PKGBUILD
    makepkg -efi

Add **exec dwm** to *~/.xinitrc*.

Install **yaourt** for the AUR

    git clone https://aur.archlinux.org/package-query.git
    git clone https://aur.archlinux.org/yaourt.git

    cd package-query
    makepkg -i

    cd yaourt
    makepkg -i

Install **vim** Vundle plugins

    vim +PluginInstall +qal
