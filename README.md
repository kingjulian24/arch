# Arch Linux - Macbook Pro 9.2 (2012)

## Preparations

### USB (OSX)

Download iso and put it on a usb stick.

    diskutil unmount /dev/disk
    dd if=/path/to/arch.iso of=/dev/rdisk1 bs=1m
    diskutil eject /dev/diskX

Boot to USB.

### Partition

Partition disk. For EFI partition, set the size to 512M and type ef00.

    cgdisk /dev/sda

#### Format

Format linux partition as ext4 and efi partition as fat 32.

    mkfs.ext4 /dev/sdaX
    mkfs.fat -F32 /dev/sdaX

#### Mount

Mount partitions.

    mount /dev/sdaX /mnt
    mkdir /mnt/boot
    mount /dev/sdaX /mnt/boot

## Install

### Configure base system

Edit the mirror list */etc/pacman.d/mirrorlist*.

    pacstrap -i /mnt base base-devel git
    genfstab -U -p /mnt >> /mnt/etc/fstab

Chroot into */mnt*.

    arch-chroot /mnt /bin/bash

Run *configure.sh*.

## Post Installation

### Display

#### Xorg

    pacman -S xorg-server xorg-xdm qiv
    pacman -S xorg-xinit xorg-xdpyinfo
	
Copy skeleton files for xorg. 

    cp /etc/skel/.xinitrc /etc/skel/.xsession ~/
    chmod 744 ~/.xinitrc ~/.xsession

Enable the xdm system service.

    systemctl enable xdm

Have nvidia generate the xorg.conf file.

    nvidia-xconfig

Edit */etc/X11/xdm/Xsetup_0* for custom wallpapers. 

    /usr/bin/qiv -zr /usr/local/share/wallpapers/*

Add wallpapers to */usr/local/share/wallpapers*.
Add **exec dwm** to *~/.xinitrc*.

#### NVIDIA driver

The 9.1 Macbook Pro has an nvidia driver for linux. Kernel headers are also needed.

    pacman -S kernel26-headers
    curl -O -L http://us.download.nvidia.com/XFree86/Linux-x86_64/340.46/NVIDIA-Linux-x86_64-340.46.run
    sh NVIDIA-Linux-x86_64-340.46.run

#### Window Manager

    pacman -S xf86-input-synaptics abs dmenu rxvt-unicode 

Initial dwm setup. 

    abs community/dwm
    cp -r /var/abs/community/dwm /home/nripoll/dwm
    cd /home/nripoll/dwm
    makepkg -i

Make any custom changes to *~/dwm/config.h* and rebuild.

    makepkg -g >> PKGBUILD
    makepkg -efi

#### Browser

Download and install Google Chrome from the AUR.

    curl -L -O https://aur.archlinux.org/packages/go/google-chrome/google-chrome.tar.gz
    tar -xvf google-chrome.tar.gz
    cd google-chrome
    makepkg -s
    pacman -U google-chrome-XXXXXX-x86_64.pkg.tar.xz
