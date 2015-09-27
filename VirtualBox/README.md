[new]: ./img/new.jpg "NEW VIRTUAL"
[os]:  ./img/os.jpg  "ARCH GUEST"
[mem]: ./img/mem.jpg "ALLOCATE MEMORY"
[hd1]: ./img/hd1.jpg "NEW HARD DISK"
[hd2]: ./img/hd2.jpg "HARD DISK TYPE"
[hd3]: ./img/hd3.jpg "HARD DISK STORAGE TYPE"
[hd4]: ./img/hd4.jpg "HARD DISK LOCATION AND SIZE"
[efi]: ./img/efi.jpg "ENABLE EFI"
[iso]: ./img/iso.jpg "LOAD ARCH ISO"

# Virtual Box

## Creating The Guest Machine
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
