#!/bin/bash

# edit sudoer file
cd /tmp
echo "$(curl -fsSL https://raw.githubusercontent.com/nelsonripoll/arch/master/config/sudoers/sudoers)" > sudoers
EDITOR="cp sudoers" visudo

echo "$(curl -fsSL https://raw.github.com/nelsonripoll/arch/master/tools/desktop_install.sh)" > desktop_install.sh
chmod +x desktop_install.sh

# Create a user
echo "Creating new user......"
echo -n "Enter username: "
read username
useradd -m -G wheel -s /bin/bash $username
passwd $username

# promp user to run desktop install
echo "run: . desktop_install.sh"
# Switch user
su $username




