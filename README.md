# Arch Linux - Macbook Pro 9.2 (2012)

## Preparations

### USB (OSX)

Download iso and put it on a usb stick.

    diskutil unmount /dev/disk
    dd if=/path/to/arch.iso of=/dev/rdisk1 bs=1m
    diskutil eject /dev/diskX

Boot to USB.

### PARTITION

Partition disk. For EFI partition, set the size to 512M and type ef00.

    cgdisk /dev/sda

Format linux partition as ext4 and efi partition as fat 32.

    mkfs.ext4 /dev/sdaX
    mkfs.fat -F32 /dev/sdaX

Mount partitions.

    mount /dev/sda1 /mnt
    mkdir /mnt/boot
    mount /dev/sda2 /mnt/boot

## Install

### Configure base system

Edit the mirror list */etc/pacman.d/mirrorlist*.

    pacstrap -i /mnt base base-devel
    genfstab -U -p /mnt >> /mnt/etc/fstab

Chroot into */mnt/*.

    arch-chroot /mnt /bin/bash

Set locale.

    locale-gen
    export LANG=en_US.UTF-8
    echo LANG=$LANG > /etc/locale.conf

Set timezone.
    
    ln -s /usr/share/zoneinfo/US/Central

Set hardware clock.
    
    hwclock --systohc --utc
    
Set hostname and make sure it's added to */etc/hosts* as well.

    echo nripoll-arch > /etc/hostname

Create initial ramdisk environment.

    mkinitcpio -p linux

Create user. Use **visudo** to make any sudo changes for the new user.

    useradd -m -G wheel -s /bin/bash nripoll
    passwd nripoll

### Boot partition (Gummiboot)

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

## Post Installation

### Wireless

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

Create */etc/systemd/system/network-wireless@.service*.

    [Unit]
    Description=Wireless network connectivity (%i)
    Wants=network.target
    Before=network.target
    BindsTo=sys-subsystem-net-devices-%i.device
    After=sys-subsystem-net-devices-%i.device
    
    [Service]
    Type=oneshot
    RemainAfterExit=yes
    
    ExecStart=/usr/bin/ip link set dev %i up
    ExecStart=/usr/bin/wpa_supplicant -B -i %i -c /etc/wpa_supplicant/wifi.conf
    ExecStart=/usr/bin/dhcpcd %i
    
    ExecStop=/usr/bin/ip link set dev %i down
    
    [Install]
    WantedBy=multi-user.target

Enable new systemd service.

    systemctl enable network-wireless@wlan0.service
    systemctl start network-wireless@wlan0.service


### Display

When installing xorg, omit all the video packages (^9-34)

    pacman -S xorg xorg-xinit xorg-xdm nvidia xf86-input-synaptics abs dmenu qiv rxvt-unicode

Copy skeleton files for xorg. 

    cp /etc/skel/.xinitrc /etc/skel/.xsession ~/
    chmod 744 ~/.xinitrc ~/.xsession

Enable the xdm system service.

    systemctl enable xdm

Have nvidia generate the xorg.conf file.

    nvidia-xconfig

Initial dwm setup. 

    abs community/dwm
    cp -r /var/abs/community/dwm /home/nripoll/dwm
    cd /home/nripoll/dwm
    makepkg -i

Make any custom changes to *~/dwm/config.h* and rebuild.
    makepkg -g >> PKGBUILD
    makepkg -efi

Edit */etc/X11/xdm/Xsetup_0* to configure xdm. Add wallpapers to */usr/local/share/wallpapers*.
Make sure you add **exec dwm** to *~/.xinitrc*.
