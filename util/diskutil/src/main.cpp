//============================================================================|
//  _______ _________          _______  _______                               |
//  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                             |
//  | (    \/   ) (   | )   ( || (    \/| (    )|                             |
//  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.      |
//  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.      |
//  | (         | |   | (   ) || (      | (\ (                                |
//  | (____/\   | |   | )   ( || (____/\| ) \ \__                             |
//  (_______/   )_(   |/     \|(_______/|/   \__/                             |
//============================================================================|

#include "partlib/Image.hpp"

#include <iostream>
#include <ctime>
#include <cstdlib>

int main(int argc, char** argv)
{
    std::string output{ "./disk.img" };
    std::string mbr{ "./build/main.mbr" };
    std::string fat12bs{ "./build/fat12.mbr" };
    std::string espImage{ "./build/esp.img" };
    std::string loader{ "./build/loader.bin" };
    std::string ebfs{ "./build/boot" };
    size_t size{ 0x10000000 };

    srand(time(nullptr));

    std::cout << "\033[1;34mEther Disk Utility v1.0.0\033[0m\n";

    for (int i = 1; i < argc; ++i)
    {
        std::string arg = argv[i];

        if (arg == "v" || arg == "--version")
            return 0;
        else if (arg == "-h" || arg == "--help")
        {
            std::cout << "Usage: diskutil\n"
                << "  (-v|--version) Show the current version of the utility\n"
                << "  (-h|--help) Show this message\n"
                << "  (-o|--output) Specify the output filename\n"
                << "  (-mbr|--mbr) Specify the master boot record filename\n"
                << "  (-fb|--fat-boot-sector) Specify the boot sector to use with FAT12\n"
                << "  (-esp|--esp-image) Path to the EFI system partition image\n"
                << "  (-l|--loader) Path to OS loader\n"
                << "  (-b|--boot) Path to boot directory\n"
                << "\n";
            return 0;
        }
        else if (arg == "-o" || arg == "--output")
        {
            output = argv[++i];
        }
        else if (arg == "-mbr" || arg == "--mbr")
        {
            mbr = argv[++i];
        }
        else if (arg == "-fb" || arg == "--fat-boot-sector")
        {
            fat12bs = argv[++i];
        }
        else if (arg == "-esp" || arg == "--esp-image")
        {
            espImage = argv[++i];
        }
        else if (arg == "-l" || arg == "--loader")
        {
            loader = argv[++i];
        }
        else if (arg == "-b" || arg == "--boot")
        {
            ebfs = argv[++i];
        }
        else
        {
            std::cout << "\033[1;31mUnsupported argument " << arg << "\033[0m\n";
            return 1;
        }
    }

    Image* image = new Image(size, mbr, fat12bs, espImage, loader, ebfs);

    if (!image->write(output))
    {
        std::cout << "\033[1;31mEther Disk Utility: Could not write image.\033[0m\n";
        return 1;
    }

    delete image;
    image = nullptr;

    std::cout << "\033[1;34mEther Disk Utility: Disk image created.\033[0m\n";

    return 0;
}
