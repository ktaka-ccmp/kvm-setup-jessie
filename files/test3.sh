#!/bin/bash

QEMU=/kvm/qemu/qemu-2.6.0/bin/qemu-system-x86_64

$QEMU \
-drive file=/kvm/data/test.img,if=virtio \
-cpu host -m 1024 -smp 2 -rtc base=localtime --enable-kvm \
-net nic,vlan=0,macaddr=52:54:00:1f:00:7b,model=virtio \
-net tap,vlan=0,script=/kvm/etc/qemu-ifup,ifname=test \
-nographic 

