# Arch Linux Virtual Box
##
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

    pacstrap -i /mnt base base-devel git zsh
    genfstab -U -p /mnt >> /mnt/etc/fstab

Chroot into */mnt*.

    arch-chroot /mnt /bin/zsh
    git clone https://github.com/nelsonripoll/arch.git
    cd arch
    sh setup.sh

Edit the sudoers file to give the wheel root access with **visudo**

    
Enable wired network where interface can be retrieved from **ip link**

    systemctl enable dhcpcd@interface.service

Enable the xdm system service.
    sudo systemctl enable xdm

Add wallpapers to */usr/local/share/wallpapers*.

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
