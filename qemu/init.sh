#!/bin/bash

if ! [ -f alpine.iso ]; then
    curl -L -o alpine.iso http://dl-cdn.alpinelinux.org/alpine/v3.11/releases/x86_64/alpine-virt-3.11.3-x86_64.iso
else
    echo Using existing alpine.iso CD
fi

if ! [ -f alpine.qcow ]; then
    qemu-img create -f qcow2 alpine.qcow 2G
    qemu-system-x86_64 -hda alpine.qcow -cdrom alpine.iso -net nic -net user -localtime -m 1024
else
    echo Using existing alpine.qcow disk
fi

echo Ready to go. Exposing ssh on port 2222 of host.
if qemu-img snapshot -l alpine.qcow | grep init; then
    snapshot="-loadvm init"
fi
qemu-system-x86_64 -hda alpine.qcow -net nic -net user,hostfwd=tcp::2222-:22 -localtime -m 1024 $snapshot