# Arch Linux Guest In VirtualBox
[new]:   ./img/vb/new.jpg     "NEW VIRTUAL"
[os]:    ./img/vb/os.jpg      "ARCH GUEST"
[mem]:   ./img/vb/mem.jpg     "ALLOCATE MEMORY"
[hd1]:   ./img/vb/hd1.jpg     "NEW HARD DISK"
[hd2]:   ./img/vb/hd2.jpg     "HARD DISK TYPE"
[hd3]:   ./img/vb/hd3.jpg     "HARD DISK STORAGE TYPE"
[hd4]:   ./img/vb/hd4.jpg     "HARD DISK LOCATION AND SIZE"
[efi]:   ./img/vb/efi.jpg     "ENABLE EFI"
[iso]:   ./img/vb/iso.jpg     "LOAD ARCH ISO"
[boot]:  ./img/arch/boot.jpg  "BOOT TO ISO"
[pre]:   ./img/arch/pre.jpg   "BLOCK DEVICES BEFORE PARTITIONING"
[part]:  ./img/arch/part.jpg  "PARTITIONING"
[post]:  ./img/arch/post.jpg  "BLOCK DEVICES AFTER PARTITIONING"
[frmt]:  ./img/arch/frmt.jpg  "FORMATTING PARTITIONS"
[wheel]: ./img/arch/wheel.jpg "EDIT PERMISSIONS FOR WHEEL GROUP"
[urxvt]: ./img/arch/urxvt.jpg "CHANGE DWM DEFAULT TERMINAL"

## Getting Started
Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and an [Arch Linux](https://www.archlinux.org/download/) iso.

### VirtualBox
1. Open the VirtualBox application and create a new virtual machine.

 ![Create a new virtual][new]

2. Enter a name for the virtual machine. Select **Linux** for the type and **Arch Linux (64-bit)** for the version.

 ![Name is arch, type is Linux, version is Arch Linux (64-bit)][os]

3. Select an amount of memory to allocate to the virtual machine while it's powered on.

 ![Allocate memorty for virtual][mem]

4. Set up the hard disk:
  * You can create a hard disk later, but you will be unable to install an OS until one is created. If you don't create one now skip to step 8.
  * You can select an existing hard disk if you have one, if you do select it and skip to step 8.
  * You can create a new one now.

 ![Create or select existing hard disk if needed][hd1]

5. If you decided to create one now, select the type. For our purposes we're using **VDI (VirtualBox Disk Image)**.

 ![Select hard disk type if new][hd2]

6. Select if you want your hard disk to be a fixed size on the host or dynamically allocated.
  * Fixed size will allocate a folder the size of the hard disk on the host.
  * Dynamically allocated will grow in size as the guest os get's bigger but never shrink.

 ![Set storage type: dynamic or fixed][hd3]

7. Name and set the size of the hard disk folder being created on the host.

 ![Name virtual file and set max size][hd4]

8. I'm use to having a UEFI boot partition so that's what I'll be installing. We need to tell VirtualBox to boot with EFI. Select the newly created virtual and click on Settings at the top. Navigate to the system tab and check **Enable EFI (special OSes only)**. Hit **Ok** when finished.

 ![Enable efi in the virtual settings under system tab][efi]

9. Start the virtual. VirtualBox will ask you to privide the arch _.iso_ file to boot from.

 ![Start virtual and load iso][iso]

### Arch Linux
1. After you start the virtual, you will need to boot to the iso.

 ![Boot to iso][boot]

2. Use `lsblk` to get the a list of block devices. You should see one you created as _sda_ with the type **DISK**. Start partitioning it with `cgdisk /dev/sda`.

 ![List block devices before partitioning][pre]

  1. First, the boot partition ( _/boot_ ):
    * default sector
    * size = 512M
    * hex code = ef00
    * partition name = EFI
  2. Next is the root partition ( _/_ ) :
    * default sector
    * default size
    * default hex code
    * partition name = ARCH

 ![Partition disk][part]

 _Note: partition names do not have to be 'EFI' or 'ARCH'_

 Use `lsblk` again to verify the changes made.

 ![List block devices after partitioning][post]

3. Format the partitions with `mkfs`.
  * The boot partition will be formatted as **vfat 32** to support **EFI**.
  * The root partition will be formatted as **ext4**.

 ```
 mkfs.vfat -F32 /dev/sda1
 mkfs.ext4 /dev/sda2
 ```

4. Mount the partitions with `mount`.

 ```
 mount /dev/sda2 /mnt
 mkdir /mnt/boot
 mount /dev/sda1 /mnt/boot
 ```

5.  Edit the mirror list (_/etc/pacman.d/mirrorlist_) if needed. Afterwards install the base system on the root partition with `pacstrap`. You can use the flag interactive flag **-i** to prevent auto-confirmation of packages.

 ```
 pacstrap /mnt base base-devel git zsh vim-python3 python-pip xorg-server xorg-xdm xorg-xinit qiv abs dmenu rxvt-unicode yajl wget
 genfstab -U -p /mnt >> /mnt/etc/fstab
 ```

6. Chroot into _/mnt_ with `arch-chroot /mnt /bin/bash`.

7. Uncomment the wheel group in the sudoers file, use `visudo`. 
 ![Create a new virtual][wheel]

8. Set passwords for root with `passwd` and the created user(s) with `passwd username`.

9. Enable wired network with `systemctl enable dhcpcd@interface.service` where interface can be retrieved from the `ip link` command:

10. Change directories into _/tmp_, clone this project, and run the setup script.

 ```
 cd /tmp
 git clone https://github.com/nelsonripoll/arch.git
 cd arch
 sh setup.sh
 ```

11. VirtualBox looks for _/boot/EFI/BOOT/BOOTX64.EFI_ when booting with EFI enabled. If that doesn't exist, rename the boot loader and directory to match. The setup script used `bootctl install` to install the boot loader and is already set up correctly for VirtualBox.

12. `exit` then `umount -R /mnt` and finally `reboot`

## Post Installation
1. Log in as the created user. Your terminal will look funny...but we'll fix that. First finish installing **dwm**:

 ```
 cd ~/dwm
 makepkg -i
 ```

 Make any custom changes to _~/dwm/config.h_. The change we must do is set the default terminal to **urxvt** instead of **uxterm**. When finished, rebuild:

 ![Change default terminal in dwm][urxvt]

 ```
 makepkg -g >> PKGBUILD
 makepkg -ef
 ```

2. Now install **yaourt**:

 ```
 git clone https://aur.archlinux.org/package-query.git
 cd package-query
 makepkg
 sudo pacman -U --noconfirm package-query*.pkg.tar.xz
 
 git clone https://aur.archlinux.org/yaourt.git
 cd yaourt
 makepkg
 sudo pacman -U --noconfirm yaourt*.pkg.tar.xz
 ```
 The **yaourt** tool is an easy way to install packages from the AUR.

3. Install the VirtualBox guest additions from the AUR.

 ```
 yaourt virtualbox-guest-utils
 modprobe -a vboxguest vboxsf vboxvideo
 ```

4. Add wallpapers to _/usr/local/share/wallpapers_ (optional).

5. Install **vim** Vundle plugins with `vim +PluginInstall +qal`.
