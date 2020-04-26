#!/bin/sh

mbr_img="/root/mbr-rootfs.img"
ext4_img="/root/ext4-rootfs.img"
disk="/dev/mmcblk1"

[ ! -e $disk ] && echo "emmc not found!" && exit 1

if [ ! -f $mbr_img ] || [ ! -f $ext4_img ]; then
	echo "img file not found!"
	exit 1
fi

echo "none" > /sys/class/leds/sata-white/trigger
echo "none" > /sys/class/leds/sata-red/trigger
echo 0 > /sys/class/leds/sata-white/brightness
echo 1 > /sys/class/leds/sata-red/brightness

echo "flash emmc mbr..."
dd if=$mbr_img of=$disk conv=fsync

echo "flash emmc ext4 fs..."
pv -pterb $ext4_img | dd of=$disk conv=fsync bs=2M seek=1

[ "$?" = "0" ] && echo "flash done, please poweroff now then unplug USB drive!" || echo "flash fail!"

echo 0 > /sys/class/leds/sata-red/brightness
echo 1 > /sys/class/leds/sata-white/brightness
