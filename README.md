# Arch Linux Virtual Box
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
