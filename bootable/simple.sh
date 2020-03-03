#!/bin/bash -x

docker rm bootable
docker build -t dsyer/bootable .
docker create --name=bootable dsyer/bootable

rm disk.*

qemu-img create -f raw disk.img 1G
mkfs.ext4 -F disk.img

sudo mount -o loop disk.img /mnt

docker export bootable | sudo tar x -C /mnt

sudo umount /mnt

qemu-img convert -f raw -O qcow2 disk.img disk.qcow

# Boots (with manual mount of /dev/sda) but no networking
# qemu-system-x86_64 -hda disk.qcow -initrd initramfs -kernel vmlinuz -net nic -net user,hostfwd=tcp::8080-:8080 -m 4096 -localtime -append root=/dev/sda