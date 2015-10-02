# Arch Linux Guest In VirtualBox

## Getting Started
Before doing anything, download VirtualBox and an iso for Arch Linux.

### VirtualBox
Download VirtualBox [here](https://www.virtualbox.org/wiki/Downloads) and
 read the [documentation](https://www.virtualbox.org/manual/UserManual.html).

### Arch Linux
Download Arch Linux [here](https://www.archlinux.org/download/) and
 read the [beginner's guide](https://wiki.archlinux.org/index.php/Beginners'_guide).

### Virtual Machine
[new]: ./img/new.jpg "NEW VIRTUAL"
[os]:  ./img/os.jpg  "ARCH GUEST"
[mem]: ./img/mem.jpg "ALLOCATE MEMORY"
[hd1]: ./img/hd1.jpg "NEW HARD DISK"
[hd2]: ./img/hd2.jpg "HARD DISK TYPE"
[hd3]: ./img/hd3.jpg "HARD DISK STORAGE TYPE"
[hd4]: ./img/hd4.jpg "HARD DISK LOCATION AND SIZE"
[efi]: ./img/efi.jpg "ENABLE EFI"
[vid]: ./img/vid.jpg "INCREASE VIDEO MEMORY"
[iso]: ./img/iso.jpg "LOAD ARCH ISO"

# Virtual Box

## Creating The Guest Machine
Open the VirtualBox application and create a new virtual machine.

![Create a new virtual][new]

Enter a name for the virtual machine. Select **Linux** for the type and 
 **Arch Linux (64-bit)** for the version.

![Name is arch, type is Linux, version is Arch Linux (64-bit)][os]

Select an amount of memory to allocate to the virtual machine while it's powered on.

![Allocate memorty for virtual][mem]

Create a new hard disk.

![Create or select existing hard disk if needed][hd1]

For our purposes we're using **VDI (VirtualBox Disk Image)** as a hard disk type.

![Select hard disk type if new][hd2]

Select if you want your hard disk to be a fixed size on the host or dynamically allocated.
 * Fixed size will allocate a folder the size of the hard disk on the host.
 * Dynamically allocated will grow in size as the guest os get's bigger but never shrink.

![Set storage type: dynamic or fixed][hd3]

Name and set the size of the hard disk folder being created on the host.

![Name virtual file and set max size][hd4]

We'll be creating a [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) 
 boot partition.  We need to tell VirtualBox to boot with EFI. Select the newly 
 created virtual and click on Settings at the top. Navigate to the system tab and 
 check **Enable EFI (special OSes only)**. Hit **Ok** when finished.

![Enable efi in the virtual settings under system tab][efi]

Increase the video memory to whatever value you desire. VirtualBox supports either
 2D or 3D acceleration, not both.

![Increase video memory under display tab][vid]

Start the virtual. VirtualBox will ask you to privide the arch _.iso_ file to boot from.

![Start virtual and load iso][iso]

### Base Installation
[boot]:  ./img/boot.jpg  "BOOT TO ISO"
[pre]:   ./img/pre.jpg   "BLOCK DEVICES BEFORE PARTITIONING"
[part]:  ./img/part.jpg  "PARTITIONING"
[post]:  ./img/post.jpg  "BLOCK DEVICES AFTER PARTITIONING"
[frmt]:  ./img/frmt.jpg  "FORMATTING PARTITIONS"
[wheel]: ./img/wheel.jpg "EDIT PERMISSIONS FOR WHEEL GROUP"
[urxvt]: ./img/urxvt.jpg "CHANGE DWM DEFAULT TERMINAL"

After you start the virtual, you will need to boot to the iso.

![Boot to iso][boot]

Use [lsblk](http://linux.die.net/man/8/lsblk) to get the a list of block devices.
 You should see one you created in VirtualBox as _sda_ with the type **DISK**.
 Start partitioning it with [cgdisk](http://rodsbooks.com/gdisk/cgdisk.html).
 We use cgdisk because we need to have a [GPT](https://en.wikipedia.org/wiki/GUID_Partition_Table) 
 layout for our EFI boot partition.

[Linux Docs - GPT (GUID Partitioning Table)](https://en.wikipedia.org/wiki/GUID_Partition_Table)

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

_Note: partition names do not have to be 'EFI' or 'ARCH'_

[Arch Wiki - Partitioning](https://wiki.archlinux.org/index.php/Partitioning)

![Partition disk][part]

Use `lsblk` again to verify the changes made.

![List block devices after partitioning][post]

Format the partitions with `mkfs`.
 * The boot partition will be formatted as **vfat 32** to support **EFI**.
 * The root partition will be formatted as **ext4**.

[Arch Wiki - File Systems](https://wiki.archlinux.org/index.php/File_systems)

```
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
```
![Formatting with vfat on /dev/sda1 and ext4 on /dev/sda2][frmt]

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

Chroot into _/mnt_ and run the base installation script. This script will finish
 installing everything you need to have a basic installation of arch linux like
 like installing an EFI boot loader, setting up the locale and timezone. The
 installation includes installing xorg, git, zshell, dwm, vim, and python.

```
arch-chroot /mnt /bin/bash
sh -c "$(curl -fsSL https://raw.github.com/nelsonripoll/arch/master/tools/base_install.sh)"
```

### Post Installation

#### VirtualBox Utils

```
yaourt virtualbox-guest-utils

modprobe -a vboxguest vboxsf vboxvideo

cat > /etc/modules-load.d/virtualbox.conf <<EOF
vboxguest
vboxsf
vboxvideo
EOF
```

#### XDM

```
cp -f arch/config/xdm/Xresources /etc/X11/xdm/Xresources

systemctl enable xdm

mkdir /usr/local/share/wallpapers

cat > /etc/X11/xdm/Xsetup_0 <<EOF
/usr/bin/qiv -zr /usr/local/share/wallpapers/*
EOF
```

#### DWM

```
sudo abs community/dwm
```
