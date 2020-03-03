#!/bin/bash

if ! [ -f disk.qcow ]; then
    echo No disk prepared. Use init.sh to create a VM and copy it to disk.qcow.
    exit 1
else
    echo Using existing disk.qcow disk
fi

echo Ready to go. Exposing ssh on port 2222 of host.
echo Use 'CTRL-A C' to switch to monitor.
if qemu-img snapshot -l disk.qcow | grep init; then
    snapshot="-loadvm init"
fi
qemu-system-x86_64 -hda disk.qcow -net nic -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080 -localtime -m 1024 -nographic $snapshot