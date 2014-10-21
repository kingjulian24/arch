#!/usr/bin/bash

pacman -S gummiboot acpi b43-fwcutter iw wpa_supplicant

# Locale
mv /etc/locale.gen /etc/locale.gen.bkp
export LANG=en_US.utf-8

echo "Setting locale to '$LANG'."
cat << EOT > /etc/locale.gen
$LANG
EOT

locale-gen

cat << EOT > /etc/locale.conf
LANG=$LANG
EOT


# Timezone
echo "Setting timezone to 'US Central'."
ln -s /usr/share/zoneinfo/US/Central /etc/localtime


# Hardware clock
echo "Setting hardware clock to 'UTC'."
hwclock --systohc --utc


# Hostname
read -p "Enter hostname: " hostname

echo "Setting hostname to '$hostname'."
cat << EOT > /etc/hostname
$hostname
EOT

# User
read -p "Enter username for non-root user: " username

echo "Creating username '$username' as part of the 'wheel' group with bash as the default shell."
useradd -m -G wheel -s /bin/bash $username

echo "Set password for $username."
passwd $username


# Wireless
echo "Setting up wireless."

echo "Downloading broadcom driver into '/tmp'."
cd /tmp
curl -O -L http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2

echo "Extracting driver."
tar -xjf broadcom-wl-6.30.163.46.tar.bz2

echo "Installing driver."
b43-fwcutter -w "/lib/firmware" broadcom-wl-6.30.163.46.wl_apsta.o > /dev/null

# Get SSID
while true; do
	read -p "Enter SSID: " SSID
	read -p "Is '$SSID' correct? (y/n): " confirm
	case $confirm in
		[Yy]) break;;
		[Nn]) ;;
		*) echo "Please answer 'y' or 'n'.";;
	esac
done

# Get SSID passphrase
while true; do
	read -p "Enter passphrase: " passphrase
	read -p "Is '$passphrase' correct? (y/n): " confirm
	case $confirm in
		[Yy]) break;;
		[Nn]) ;;
		*) echo "Please answer 'y' or 'n'.";;
	esac
done

echo "Setting up configuration for wpa_supplicant with $SSID and $passphrase."
wpa_passphrase $SSID $passphrase > /etc/wpa_supplicant/wifi.conf

echo "Creating systemd startup script."
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

echo "Enabling script."
systemctl enable network-wireless@wlp3s0.service


# Boot loader
echo "Installing gummiboot onto '/boot'."
gummiboot --path=/boot install

echo "Creating 'arch.conf' file."
cat << EOT > /boot/loader/entries/arch.conf
title	Arch Linux
linux	/vmlinuz-linux
initrd	/initramfs-linux.img
options	root=/dev/sda2 rw
EOT

echo "Creating 'loader.conf' file."
cat << EOT > /boot/loader/loader.conf
default  arch
timeout  3
EOT


# Ramdisk
echo "Creating initial ramdisk environment."
mkinitcpio -p linux

echo "Remaining steps: add hostname to /etc/hosts and set root password."
