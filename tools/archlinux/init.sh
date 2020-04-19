#!/bin/sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# remove kernel packages
pacman -Rn --noconfirm linux-aarch64 linux-firmware

systemctl set-default multi-user.target

echo "ttyAMA0" >> ./etc/securetty

echo "/dev/root / ext4 defaults,noatime,nodiratime,errors=remount-ro 0 1" >> ./etc/fstab

# set ntp server
sed -i '/^#NTP/cNTP=time1.aliyun.com 2001:470:0:50::2' ./etc/systemd/timesyncd.conf

# set sshd_config to allow root login
sed -i '/^#PermitRootLogin/cPermitRootLogin yes' ./etc/ssh/sshd_config

# set locale
echo 'en_US.UTF8 UTF-8' > ./etc/locale.gen
locale-gen
echo 'LANG=en_US.utf8' > ./etc/locale.conf
echo 'KEYMAP=us' > ./etc/vconsole.conf
ln -sf ../usr/share/zoneinfo/Asia/Shanghai ./etc/localtime
echo "root:admin" |chpasswd

pacman-key --init
pacman-key --populate archlinuxarm

sed -i 's/CheckSpace/#CheckSpace/' ./etc/pacman.conf
pacman -Sy --noconfirm hdparm parted uboot-tools
sed -i 's/#CheckSpace/CheckSpace/' ./etc/pacman.conf

cat <<EOF > ./etc/udev/rules.d/99-hdparm.rules
ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd*",ENV{ID_BUS}=="ata", ENV{DEVTYPE}=="disk", RUN+="/usr/bin/hdparm -B 127 -S 120 \$env{DEVNAME}"

EOF

echo "/dev/mmcblk1 0x1f0000 0x10000 0x10000" > ./etc/fw_env.config
echo "imou-sn1" > ./etc/hostname

# clean
pacman -Sc --noconfirm
rm -rf ./etc/pacman.d/gnupg
killall -9 gpg-agent

rm -rf ./var/log/journal
rm -f ./var/lib/dbus/machine-id
: > ./etc/machine-id

umount /dev
umount /sys
umount /proc
