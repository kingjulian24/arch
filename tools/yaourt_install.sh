#!/bin/bash
pacman -S --noconfirm git yajl

read -r -d '' SUDOERS <<'EOF'
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

read -r -d '' CMNDS <<'EOF'
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
cd /tmp/package-query
makepkg -i --noconfirm

git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
cd /tmp/yaourt
makepkg -i --noconfirm
EOF

echo $SUDOERS >> /etc/sudoers

cp /etc/sudoers /etc/sudoers.backup

useradd -m -G wheel -s /bin/bash arch-user

su arch-user -c "$CMNDS"

userdel arch-user

mv /etc/sudoers.backup /etc/sudoers
