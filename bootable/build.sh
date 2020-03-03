#!/bin/bash -x

docker rm bootable
docker build -t dsyer/bootable .
docker create --name=bootable dsyer/bootable

rm disk.*

qemu-img create -f raw disk.img 1G

sfdisk disk.img <<EOF
label: dos
label-id: 0x5d8b75fc
device: disk.img
unit: sectors

disk.img1 : start=2048, size=2095104, type=83, bootable
EOF

OFFSET=$(expr 512 \* 2048)
sudo losetup -D
sudo losetup -o ${OFFSET} /dev/loop1  disk.img
sudo mkfs.ext3 /dev/loop1

sudo mount -t auto /dev/loop1 /mnt/

docker export bootable | sudo tar x -C /mnt

sudo extlinux --install /mnt/boot
cat <<EOF | sudo tee /mnt/boot/syslinux.cfg
DEFAULT linux
  SAY Now booting the kernel from SYSLINUX...
 LABEL linux
  KERNEL /boot/vmlinuz-virt
  APPEND ro root=/dev/sda1 initrd=/boot/initramfs-virt
EOF
sudo umount /mnt

dd if=/usr/lib/syslinux/mbr/mbr.bin of=disk.img bs=440 count=1 conv=notrunc

qemu-img convert -f raw -O qcow2 disk.img disk.qcow
