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
#include "partlib/GPT.hpp"
#include "partlib/GUID.hpp"
#include "partlib/CRC32.hpp"

#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>

#define BIOS_PARTITION_BLOCKS       64
#define EBFS_PARTITION_BLOCKS       256
#define EFI_PARTITION_BLOCKS        1000

Image::Image(const size_t size, const std::string& mbr)
    : m_size{ size }, m_image{ nullptr }, m_mbr{ mbr }
{
    if (m_size < (68 + BIOS_PARTITION_BLOCKS + EBFS_PARTITION_BLOCKS) * 0x200)
        m_size = (68 + BIOS_PARTITION_BLOCKS + EBFS_PARTITION_BLOCKS) * 0x200;

    m_image = new uint8_t[size];
    memset(m_image, 0, size);
}

Image::~Image()
{
    delete m_image;
    m_image = nullptr;
}

bool Image::write(const std::string& path)
{
    uint32_t dword = 0;

    char* entries = new char[0x80 * 4];
    memset(entries, 0, 0x80 * 4);

    GPTEntry biosEntry;
    memset(&biosEntry, 0, sizeof(biosEntry));
    memcpy(biosEntry.typeGUID, biosPartitionGUID, 16);
    generateGUID(biosEntry.uniqueGUID);
    biosEntry.firstLBA = 34;
    biosEntry.lastLBA = 34 + (BIOS_PARTITION_BLOCKS * 0x200) - 1;
    memcpy(biosEntry.partitionName, u"Ether Loader", 12 * sizeof(char16_t));
    memcpy(&entries[0], (char*)&biosEntry, 0x80);

    GPTEntry ebfsEntry;
    memset(&ebfsEntry, 0, sizeof(ebfsEntry));
    memcpy(ebfsEntry.typeGUID, ebfsPartitionGUID, 16);
    generateGUID(ebfsEntry.uniqueGUID);
    ebfsEntry.firstLBA = 34 + (BIOS_PARTITION_BLOCKS * 0x200);
    ebfsEntry.lastLBA = ebfsEntry.firstLBA + (EBFS_PARTITION_BLOCKS * 0x200) - 1;
    memcpy(ebfsEntry.partitionName, u"Ether Boot Partition", 20 * sizeof(char16_t));
    memcpy(&entries[0x80], (char*)&ebfsEntry, 0x80);

    GPTEntry mainEntry;
    memset(&mainEntry, 0, sizeof(mainEntry));
    memcpy(mainEntry.typeGUID, EtherFSPartitionGUID, 16);
    generateGUID(mainEntry.uniqueGUID);
    mainEntry.firstLBA = ebfsEntry.lastLBA + 1;
    mainEntry.lastLBA = (m_size / 0x200) - EFI_PARTITION_BLOCKS - 36;
    memcpy(mainEntry.partitionName, u"Ether Operating System", 22 * sizeof(char16_t));
    memcpy(&entries[0x100], (char*)&mainEntry, 0x80);

    GPTEntry efiEntry;
    memset(&efiEntry, 0, sizeof(efiEntry));
    memcpy(efiEntry.typeGUID, EFIPartitionGUID, 16);
    generateGUID(efiEntry.uniqueGUID);
    efiEntry.firstLBA = (m_size / 0x200) - EFI_PARTITION_BLOCKS - 35;
    efiEntry.lastLBA = (m_size / 0x200) - 35;
    memcpy(efiEntry.partitionName, u"EFI System Partition", 20 * sizeof(char16_t));
    memcpy(&entries[0x180], (char*)&efiEntry, 0x80);

    dword = 0x0F6F4E1E;                 // This is random
    memcpy(&m_image[440], (char*)&dword, sizeof(uint32_t));

    memcpy(&m_image[0x400], entries, 0x80 * 4);
    memcpy(&m_image[((m_size / 0x200) - 34) * 0x200], entries, 0x80 * 4);

    GPTHeader gpt;
    memset(&gpt, 0, sizeof(gpt));
    memcpy(gpt.signature, "EFI PART", 8);
    gpt.revision = 0x00010000;
    gpt.headerSize = 0x5C;
    gpt.headerCRC32 = 0;
    gpt.currentLBA = 1;
    gpt.backupLBA = (m_size / 0x200) - 1;
    gpt.firstUsableLBA = 34;
    gpt.lastUsableLBA = (m_size / 0x200) - 35;
    generateGUID(gpt.diskGUID);
    gpt.entriesLBA = 2;
    gpt.numEntries = 4;
    gpt.entrySize = 0x80;
    gpt.entriesCRC32 = crc32(0, entries, 0x80 * 4);
    memcpy(&m_image[0x200], (char*)&gpt, sizeof(gpt));

    gpt.currentLBA = (m_size / 0x200) - 1;
    gpt.backupLBA = 1;
    gpt.entriesLBA = (m_size / 0x200) - 34;
    memcpy(&m_image[m_size - 0x200], (char*)&gpt, sizeof(gpt));

    auto mbrfile = std::fstream(m_mbr, std::ios::in | std::ios::ate | std::ios::binary);

    if (mbrfile.tellg() != 512)
    {
        std::cout << "\033[1;31mEther Disk Utility: Invalid MBR size.\n";
        mbrfile.close();
        return false;
    }

    mbrfile.seekg(0, std::ios::beg);
    mbrfile.read((char*)&m_image[0], 512);
    mbrfile.close();

    auto fileo = std::fstream(path, std::ios::out | std::ios::binary);
    fileo.write((char*)&m_image[0], m_size);
    fileo.close();

    return true;
}
