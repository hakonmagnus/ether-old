#!/bin/bash

qemu-system-x86_64 -bios /usr/share/OVMF/OVMF_CODE.fd -enable-kvm -m 4096 -drive format=raw,file=disk.img
