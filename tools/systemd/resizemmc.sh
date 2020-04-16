#!/bin/sh

if [ -e /root/.need_resize ]; then 
	parted -s /dev/mmcblk1 -- resizepart 1 100% && resize2fs /dev/mmcblk1p1 && echo "resize done, please reboot" || echo "resize failed!"
	rm -f /root/.need_resize
fi
