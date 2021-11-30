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

#pragma once

#include <cstdint>

/**
 * \addtogroup partlib
 * @{
 */

/**
 * GPT partition table header
 */
struct __attribute__((__packed__)) GPTHeader
{
    char signature[8];          ///< EFI PART signature
    uint32_t revision;          ///< Revision
    uint32_t headerSize;        ///< Size of header in bytes
    uint32_t headerCRC32;       ///< CRC32 checksum of header
    uint32_t reserved;          ///< Reserved (zero)
    uint64_t currentLBA;        ///< Current LBA of header
    uint64_t backupLBA;         ///< Other header copy
    uint64_t firstUsableLBA;    ///< First usable LBA for partitions
    uint64_t lastUsableLBA;     ///< Last usable LBA for patitions
    uint8_t diskGUID[16];       ///< Disk unique GUID
    uint64_t entriesLBA;        ///< LBA of entries
    uint32_t numEntries;        ///< Number of entries
    uint32_t entrySize;         ///< Size of an entry
    uint32_t entriesCRC32;      ///< CRC32 checksum of entries
};

/**
 * GPT partition entry
 */
struct __attribute__((__packed__)) GPTEntry
{
    uint8_t typeGUID[16];       ///< Type of partition
    uint8_t uniqueGUID[16];     ///< Unique partition GUID
    uint64_t firstLBA;          ///< Starting LBA
    uint64_t lastLBA;           ///< Ending LBA
    uint64_t attributes;        ///< Attribute flags
    char16_t partitionName[36]; ///< Partition name in UTF-16LE
};

/**
 * BIOS boot partition GUID
 */
static uint8_t biosPartitionGUID[] { 0x48, 0x61, 0x68, 0x21, 0x49, 0x64, 0x6F,
    0x6E, 0x74, 0x4E, 0x65, 0x65, 0x64, 0x45, 0x46, 0x49 };

/**
 * EBFS partition GUID
 */
static uint8_t ebfsPartitionGUID[] { 0x9C, 0xA8, 0x64, 0x1B, 0x29, 0x0B, 0x4A,
    0xD0, 0x95, 0x35, 0x0C, 0x55, 0x3D, 0x8A, 0x01, 0xC6 };

/**
 * EtherFS partition GUID
 */
static uint8_t EtherFSPartitionGUID[] { 0xAC, 0xDB, 0xF6, 0x8B, 0x4D, 0x62, 0x47,
    0x7D, 0x85, 0x92, 0xF2, 0x14, 0x1E, 0x9A, 0x75, 0x44 };

/**
 * EFI partition GUID
 */
static uint8_t EFIPartitionGUID[] { 0x48, 0x61, 0x68, 0x21, 0x49, 0x64, 0x6F,
    0x6E, 0x74, 0x4E, 0x65, 0x65, 0x64, 0x45, 0x46, 0x49 };

/**
 * @}
 */

