#!/bin/bash

qemu-system-x86_64 -enable-kvm -m 4096 -drive format=raw,file=disk.img
