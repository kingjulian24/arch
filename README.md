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

    pacstrap -i /mnt base base-devel
    genfstab -U -p /mnt >> /mnt/etc/fstab

Chroot into */mnt*.

    arch-chroot /mnt /bin/bash

#### Locale, timezone, and hardware clock

Set locale.

    locale-gen
    export LANG=en_US.UTF-8
    echo LANG=$LANG > /etc/locale.conf

Set timezone.
    
    ln -s /usr/share/zoneinfo/US/Central

Set hardware clock.
    
    hwclock --systohc --utc
    
#### Hostname

Set hostname and make sure it's added to */etc/hosts* as well.

    echo nripoll-arch > /etc/hostname

#### Users, groups, and passwords

Create user. Use **visudo** to make any sudo changes for the new user.

    useradd -m -G wheel -s /bin/bash nripoll
    passwd nripoll


#### Battery

    pacman -S acpi

#### Wireless

Install **b43-fwcutter**, **iw**, and **wpa_supplicant**. 

    pacman -S b43-fwcutter iw wpa_supplicant

Download and install broadcom drivers.

    cd /tmp
    curl -O http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2
    tar xjf broadcom-wl-6.30.163.46.tar.bz2
    sudo b43-fwcutter -w "/lib/firmware" broadcom-wl-6.30.163.46.wl_apsta.o

Use **wpa_passphrase** to create the wpa_supplicant conf file.
Make sure it gets properly formatted afterwards.

    echo $(wpa_passphrase ssid passphrase) > /etc/wpa_supplicant/wifi.conf

Save systemd wireless file at */etc/systemd/system/network-wireless@.service*.

Enable new systemd service.

    systemctl enable network-wireless@wlp3s0.service

#### Configure boot partition

Install **gummiboot**.

    pacman -S gummiboot 
    /usr/bin/gummiboot --path=/boot install

Create */boot/loader/entries/arch.conf*.

    title          Arch Linux
    linux          /vmlinuz-linux
    initrd         /initramfs-linux.img
    options        root=/dev/sda2 rw

Edit */boot/loader/loader.conf*.

    default  arch
    timeout  5

Exit and unmount partitions.

#### Ramdisk

Create initial ramdisk environment.

    mkinitcpio -p linux

## Post Installation

### Display

#### NVIDIA driver

The 9.1 Macbook Pro has an nvidia driver for linux.

    curl -O -L http://us.download.nvidia.com/XFree86/Linux-x86_64/340.46/NVIDIA-Linux-x86_64-340.46.run
    sh NVIDIA-Linux-x86_64-340.46.run

#### Xorg

    pacman -S xorg xorg-xdm qiv
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
