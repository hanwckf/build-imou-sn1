#!/bin/sh

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

add_svc(){
	runlevel="$1"
	svcs="$2"
	for svc in ${svcs}; do
		if [ -f ./etc/init.d/${svc} ]; then
			ln -sf /etc/init.d/${svc} ./etc/runlevels/${runlevel}/${svc}
		fi
	done
}

apk update --no-progress && \
	apk add --no-progress alpine-base haveged parted \
	e2fsprogs-extra coreutils uboot-tools pv tzdata hdparm \
	dropbear dropbear-scp

echo "root:admin" | chpasswd

add_svc "sysinit" "sysfs procfs devfs mdev"

add_svc "boot" "urandom swclock sysctl modules hostname bootmisc syslog networking"

add_svc "default" "crond haveged ntpd dropbear"

add_svc "shutdown" "killprocs mount-ro savecache"

sed -i '/^tty[2-6]/d' ./etc/inittab

echo "ttyAMA0::respawn:/sbin/getty -L ttyAMA0 115200 vt100" >> ./etc/inittab
echo "ttyAMA0" >> ./etc/securetty
echo "/dev/mmcblk1 0x1f0000 0x10000 0x10000" > ./etc/fw_env.config

sed -i 's/pool.ntp.org/time1.aliyun.com/' ./etc/conf.d/ntpd
ln -sf /usr/share/zoneinfo/Asia/Shanghai ./etc/localtime

echo "alpine" > ./etc/hostname

cat > ./etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
	hostname alpine

EOF

