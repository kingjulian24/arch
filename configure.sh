#!/usr/bin/bash

current_dir=$(pwd)
cd /tmp

# Locale
export LANG=en_US.utf-8
echo $LANG > /etc/locale.gen
echo LANG=$LANG > /etc/locale.conf
mv /etc/locale.gen /etc/locale.gen.bkp
locale-gen


# Timezone
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# Hardware clock
hwclock --systohc --utc


# Hostname
hostname=$(read_input "Enter hostname: ")
echo $hostname > /etc/hostname


# User
username=$(read_input "Enter username: ")
useradd -m -G wheel -s /bin/bash $username
passwd $username


# Wireless driver
curl -O -L http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2
tar -xjf broadcom-wl-6.30.163.46.tar.bz2
b43-fwcutter -w "/lib/firmware" broadcom-wl-6.30.163.46.wl_apsta.o > /dev/null


# Wireless connection config
ssid=$(read_input("Enter SSID: "))
passphrase=$(read_input("Enter SSID passphrase: "))
wpa_passphrase $ssid $passphrase > /etc/wpa_supplicant/wifi.conf


# Wireless connection at startup
cat << EOT > /etc/systemd/system/network-wireless@.service
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
EOT

systemctl enable network-wireless@wlp3s0.service


# Boot loader
gummiboot --path=/boot install

cat << EOT > /boot/loader/entries/arch.conf
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	root=/dev/sda2 rw
EOT

cat << EOT > /boot/loader/loader.conf
default  arch
timeout  3
EOT


# Ramdisk
mkinitcpio -p linux


cd $current_dir
echo "Remaining steps: add hostname to /etc/hosts and set root password."

read_input() {
while true; do
	read -p $1 value 
	read -p "Is '$value' correct? (y/n): " confirm
	case $confirm in
		[Yy]) break;;
		[Nn]) ;;
		*) echo "Please answer 'y' or 'n'.";;
	esac
done

echo $value
}
