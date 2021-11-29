#!/bin/bash

qemu-system-x86_64 -bios /usr/share/OVMF/OVMF_CODE.fd -enable-kvm -m 4096 -boot d -cdrom ether-1.0.0-celeritas.iso

