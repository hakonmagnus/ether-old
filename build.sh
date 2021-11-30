#!/bin/bash

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -s|--size)
            SIZE="$2"
            shift
            shift
            ;;
        -v|--version)
            VERSION=true
            shift
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        *)
            ERROR=true
            shift
            ;;
    esac
done

echo -e "\e[1;32mEther Build Utility v1.0.0\e[0m"
echo ""

if [ $ERROR ]
then
    echo "Ether Build Utility: ERROR: Unsupported argument."
    exit 1
fi

if [ $HELP ]
then
    echo "Usage: build.sh"
    echo "  (-s|--size) Size of disk image"
    echo "  (-v|--version) Print version"
    echo "  (-h|--help) Show this message"
    echo ""
    exit 0
fi

if [ $VERSION ]
then
    echo "Ether Build Utility Version 1.0.0"
    echo "For Ether 1.0 Celeritas"
    echo ""
    exit 0
fi

# Create build directory

mkdir -p build
mkdir -p ./build/installer

# CMake

cd build
cmake ..
make
cd ..

# Assemble

echo -e "\e[1;32mBuilding loaders...\e[0m"
nasm ./mbr/iso.asm -o ./build/installer/iso.mbr
nasm ./mbr/main.asm -o ./build/main.mbr
nasm ./loader/loader.asm -o ./build/loader.bin
nasm ./efi/efi.asm -o ./build/boot.efi

# Create hard drive image

./build/util/diskutil/diskutil

# Create installer ISO

echo -e "\e[1;32mBuilding installer...\e[0m"

mkdir -p ./build/installer/boot
dd if=/dev/zero of=./build/installer/boot.catalog count=2048
nasm ./isoloader/isoloader.asm -o ./build/installer/boot.bin
dd if=/dev/zero of=./build/installer/efi.img count=4 bs=1M
mkfs.vfat ./build/installer/efi.img

cp ./build/boot.efi ./build/installer/boot.efi
cp ./build/loader.bin ./build/installer/boot/loader.bin

echo -e "\e[1;32mWriting installer ISO...\e[0m"

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
#xorriso -dev ./ether-1.0.0-celeritas.iso -volid 'Ether 1.0 Celeritas' -commit

echo -e "\e[1;32mDone!\e[0m"
