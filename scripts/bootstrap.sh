echo "> Partition Disk"
sfdisk /dev/sda << EOF
label: dos
, 512M, L, *
, , L,
EOF

echo "> Make File Systems"
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

echo "> Install base-system and grub"
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
yes | xbps-install -Sy -r /mnt -R https://alpha.de.repo.voidlinux.org/current \
  base-system base-devel grub curl vim python python3 dbus virtualbox-ose-guest

echo "> Prepare chroot"
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
mount -t devpts pts /mnt/dev/pts
mv /root/install.sh /mnt/install.sh
chmod +x /mnt/install.sh
cp /etc/resolv.conf /mnt/etc/resolv.conf

echo "> Enter chroot"
chroot /mnt "/install.sh"

echo "> Cleanup installer"
sync
rm /mnt/install.sh
sudo umount -R /mnt
