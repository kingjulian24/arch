[boot]:  ./img/boot.jpg  "BOOT TO ISO"
[pre]:   ./img/pre.jpg   "BLOCK DEVICES BEFORE PARTITIONING"
[part]:  ./img/part.jpg  "PARTITIONING"
[post]:  ./img/post.jpg  "BLOCK DEVICES AFTER PARTITIONING"
[frmt]:  ./img/frmt.jpg  "FORMATTING PARTITIONS"
[wheel]: ./img/wheel.jpg "EDIT PERMISSIONS FOR WHEEL GROUP"
[urxvt]: ./img/urxvt.jpg "CHANGE DWM DEFAULT TERMINAL"

# Arch Linux Base Installation

After you start the virtual, you will need to boot to the iso.

![Boot to iso][boot]

Use `lsblk` to get the a list of block devices.
 You should see one you created as _sda_ with the type **DISK**.
 Start partitioning it with `cgdisk /dev/sda`.

![List block devices before partitioning][pre]

1. First, the boot partition (_/dev/sda1_):
 * default sector
 * size = 512M
 * hex code = ef00
 * partition name = EFI
2. Next is the root partition (_/dev/sda2_) :
 * default sector
 * default size
 * default hex code
 * partition name = ARCH

![Partition disk][part]

_Note: partition names do not have to be 'EFI' or 'ARCH'_

Use `lsblk` again to verify the changes made.

![List block devices after partitioning][post]

Format the partitions with `mkfs`.
 * The boot partition will be formatted as **vfat 32** to support **EFI**.
 * The root partition will be formatted as **ext4**.

```
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
```

Mount the partitions with `mount`.

```
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

Edit the mirror list (_/etc/pacman.d/mirrorlist_) if needed.
 Afterwards install the base system on the root partition with `pacstrap`.
 You can use the flag interactive flag **-i** to prevent auto-confirmation of packages.

```
pacstrap /mnt base base-devel
genfstab -U -p /mnt >> /mnt/etc/fstab
```

Chroot into _/mnt_. First thing you need to do is set the locale, timezone,
 hardware clock, and hostname.

```
arch-chroot /mnt /bin/bash

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "localhost" > /etc/hostname

locale-gen 

ln -s /usr/share/zoneinfo/US/Central /etc/localtime

hwclock --systohc --utc
```

Install the boot loader.

```
bootctl install
```

Open a new file at _/boot/loader/entries/arch.conf_ and add the following:

```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
```

Open another file at _/boot/loader/loader.conf_ and add the following:

```
default arch
timeout 3
```

VirtualBox looks for _/boot/EFI/BOOT/BOOTX64.EFI_ when booting with EFI
 enabled. `bootctl` took care of that already but if you used a different
 boot loader make sure your directory matches the path VirtualBox is
 looking for.

Uncomment the wheel group in the sudoers file, use `visudo`.

![Create a new virtual][wheel]

Create a new user as part of the wheel group. We'll run into some things 
 we can't do as root but will need sudo.  Set passwords for root and the
 created user(s).

```
useradd -m -G wheel -s /bin/zsh username
passwd
passwd username
```

Enable the wired network where interface can be retrieved from the `ip link` command:

```
systemctl enable dhcpcd@interface.service

```

Create the initramfs, exit, unmount then reboot.
```
mkinitcpio -p linux
exit
umount -R /mnt
reboot
```
