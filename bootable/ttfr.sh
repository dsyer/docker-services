#!/bin/bash

start_time="$(date -u +%s.%N)"
qemu-system-x86_64 -hda disk.qcow -boot d -net nic -net user,hostfwd=tcp::8080-:8080 -localtime -m 4096 -smp 8 -loadvm petclinic4 -nographic &
while ! curl localhost:8080 2>&1 > /dev/null; do
	sleep 0.01
done
end_time="$(date -u +%s.%N)"
curl -w '\n' localhost:8080
elapsed="$(bc <<< $end_time-$start_time)"
echo "Total of $elapsed seconds elapsed for process"
echo "Run 'pkill qemu' to kill the VM"
