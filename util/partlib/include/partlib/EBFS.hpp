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
#include <string>
#include <vector>

using std::size_t;

/**
 * \addtogroup partlib
 * @{
 */

/**
 * Directory info struct
 */
struct EBFSDirectoryInfo
{
    std::string name;
    std::string path;
    bool isDir;
    bool isRoot;
    std::vector<EBFSDirectoryInfo*> children;
    EBFSDirectoryInfo* parent;
    size_t size;
    uint32_t inode;
};

/**
 * EBFS superblock structure
 */
struct __attribute__((__packed__)) EBFSSuperblock
{
    uint16_t signature;
    uint16_t version;
    uint32_t blockSize;
    uint32_t groupSize;
    uint32_t freeGroups;
    uint32_t totalInodes;
    uint32_t freeInodes;
    uint32_t inodeSize;
    uint32_t lastMountTime;
    uint32_t lastWriteTime;
    uint32_t rootDirectory;
    uint32_t inodes;
};

/**
 * EBFS directory entry structure
 */
struct __attribute__((__packed__)) EBFSDirectoryEntry
{
    uint32_t inode;
    uint8_t type;
    uint8_t reserved;
    uint16_t entrySize;
};

/**
 * EBFS Inode structure
 */
struct __attribute__((__packed__)) EBFSInode
{
    uint16_t type;
    uint16_t reserved;
    uint32_t fileSize;
    uint32_t lastAccessTime;
    uint32_t createdTime;
    uint32_t modifiedTime;
    uint32_t firstGroup;
};

/**
 * EBFS Group header
 */
struct __attribute__((__packed__)) EBFSGroupHeader
{
    uint8_t type;
    uint8_t reserved0;
    uint32_t nextGroup;
    uint32_t crc32;
    uint8_t reserved[6];
};

/**
 * EBFS class
 */
class EBFS
{
public:
    /**
     * Constructor
     * \param size Size of EBFS
     * \param blockSize Block size in bytes
     * \param groupSize Number of blocks per group
     * \param numInodes Number of inodes
     * \param root Path to root directory
     */
    EBFS(const size_t size, const uint32_t blockSize, const uint32_t groupSize,
        const uint32_t numInodes, const std::string& root);
    
    /**
     * Destructor
     */
    ~EBFS();
    
    /**
     * Write EBFS
     * \return Pointer to EBFS buffer
     */
    uint8_t* write();
    
private:
    /**
     * Image
     */
    uint8_t* m_image;
    
    /**
     * Size in bytes
     */
    size_t m_size;
    
    /**
     * Size of a block
     */
    uint32_t m_blockSize;
    
    /**
     * Size of a group
     */
    uint32_t m_groupSize;
    
    /**
     * Total number of inodes
     */
    uint32_t m_numInodes;
    
    /**
     * Root directory
     */
    std::string m_root;
};

/**
 * @}
 */
