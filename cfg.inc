tmpdir="tmp"
output="output"
rootfs_mount_point="/mnt/${os}_rootfs"
qemu_static="./tools/qemu/qemu-aarch64-static"

cur_dir=$(pwd)
device_name="imou-sn1-${kernel_ver}"
DTB=hi3798cv200-imou-sn1.dtb
