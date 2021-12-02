[![Build Status](https://app.travis-ci.com/hakonmagnus/ether.svg?branch=master)](https://app.travis-ci.com/hakonmagnus/ether)
[![Contributors](https://img.shields.io/github/contributors/hakonmagnus/ether)](https://github.com/hakonmagnus/ether/commits)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![codecov](https://codecov.io/gh/hakonmagnus/ether/branch/master/graph/badge.svg?token=7CS3A5V6B0)](https://codecov.io/gh/hakonmagnus/ether)

<p align="center">
  <a href="https://ether-os.com">
    <img
      alt="Ether Operating System"
      src="https://github.com/hakonmagnus/ether/blob/master/docs/ether.png"
      width="250"
      height="250"
    />
  </a>
</p>

Ether is a 64-bit POSIX operating system for the x86 architecture written in Assembly.
It is optimized for size and speed, and makes use of advanced features of the x86 instruction
set.

**This project is bound by a [Code of Conduct](CODE_OF_CONDUCT.md)**

## Table of Contents

* [Screenshots](#screenshots)
* [Release History](#release-history)
* [Getting Started](#getting-started)
  * [Cloning](#cloning)
  * [Building](#building)
  * [Installing](#installing)
* [Contributing](#contributing)
* [LICENSE](#LICENSE)

## Screenshots

## Release History

| Version Number | Version Name | Date | Release notes |
|----------------|--------------|------|---------------|
| 1.0.0          | 1.0 Celeritas | TBD | Initial release |

## Getting Started

This section explains how to get Ether Operating System up and running.

### Cloning

Run the following commands in a UNIX terminal:

```
git clone https://github.com/hakonmagnus/ether.git
cd ether
git submodule update --init --recursive
chmod +x build.sh
```

### Dependencies

The following are needed to run the build script:

* CMake
* G++/GCC
* NASM
* xorriso
* mkfs.vfat

Make sure these dependencies are installed prior to running the build script.

### Building

To build Ether, run the following:

```
sudo ./build.sh
```

Sudo privileges are required to mount the FAT EFI partition while building.
We won't destroy your computer, don't worry.

### Installing

The build utility will generate both an ISO image for the installer and a
raw hard drive image which can be executed by any virtual machine. The following
run scripts exist:

* qemu-iso.sh - Runs QEMU under legacy BIOS from the ISO image
* qemu-iso-uefi.sh - Runs QEMU using OVMF UEFI BIOS from the ISO image
* qemu.sh - Runs QEMU under legacy BIOS using the hard drive image
* qemu-uefi.sh - Runs QEMU using OVMF UEFI BIOS using the hard drive image

**Note: You should run this under sudo since it uses KVM by default**

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## License

Please see [LICENSE](LICENSE)
