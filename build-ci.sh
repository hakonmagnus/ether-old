#!/bin/bash

echo -e "\e[1;32mEther Build Utility CI v1.0.0\e[0m"
echo ""

# Create build directory

mkdir -p build
mkdir -p ./build/installer

# CMake

cd build
cmake .. -DCMAKE_BUILD_TYPE=Coverage
make
make ether_coverage
ctest
cd ..

# Assemble

nasm ./mbr/iso.asm -o ./build/installer/iso.mbr
nasm ./loader/loader.asm -o ./build/loader.bin
nasm ./efi/efi.asm -o ./build/boot.efi

# Create installer ISO

mkdir -p ./build/installer/boot
dd if=/dev/zero of=./build/installer/boot.catalog count=2048
nasm ./isoloader/isoloader.asm -o ./build/installer/boot.bin
dd if=/dev/zero of=./build/installer/efi.img count=4 bs=1M
mkfs.vfat ./build/installer/efi.img

cp ./build/boot.efi ./build/installer/boot.efi
cp ./build/loader.bin ./build/installer/boot/loader.bin

sudo mkdir -p /mnt/etheriso
sudo mount ./build/installer/efi.img /mnt/etheriso
sudo mkdir /mnt/etheriso/EFI
sudo mkdir /mnt/etheriso/EFI/BOOT
sudo cp ./build/installer/boot.efi /mnt/etheriso/EFI/BOOT/BOOTX64.EFI
sudo umount /mnt/etheriso

xorriso -as mkisofs \
    -o ether-1.0.0-celeritas.iso \
    -isohybrid-mbr ./build/installer/iso.mbr \
    -b boot.bin \
     -no-emul-boot -boot-load-size 8 -boot-info-table \
    -c boot.catalog \
    -eltorito-alt-boot \
    -e efi.img \
     -no-emul-boot \
     -isohybrid-gpt-basdat \
    ./build/installer
