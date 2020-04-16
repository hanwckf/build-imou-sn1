setenv rootdev "/dev/mmcblk1p1"
setenv verbosity "7"
setenv rootfstype "ext4"

$load_bootpart_cmd ${boot_interface} ${devnum}:1 ${scriptaddr} ${prefix}uEnv.txt
env import -t ${scriptaddr} ${filesize}

setenv bootargs "root=${rootdev} rootfstype=${rootfstype} rootwait loglevel=${verbosity} ${extraargs}"

setenv fdt_name_a hi3798cv200-imou-sn1.dtb

$load_bootpart_cmd $boot_interface 0:1 $kernel_addr_r ${prefix}$image_name
$load_bootpart_cmd $boot_interface 0:1 $fdt_addr_r ${prefix}$fdt_name_a

booti $kernel_addr_r - $fdt_addr_r
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr

