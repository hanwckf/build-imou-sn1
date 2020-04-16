#!/bin/sh

parted /dev/mmcblk1 resizepart 1 Yes 100% && resize2fs /dev/mmcblk1p1 && echo "resize done, please reboot" || echo "resize failed!"
