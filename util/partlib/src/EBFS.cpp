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

#include "partlib/EBFS.hpp"

#include <cstdlib>
#include <cstring>
#include <chrono>
#include <fstream>
#include <algorithm>
#include <iostream>

#include <dirent.h>
#include <sys/types.h>
#include <unistd.h>

void fetchTree(const std::string path,
    std::vector<EBFSDirectoryInfo*>& tree,
    EBFSDirectoryInfo* current = nullptr,
    const std::string name = "")
{
    if (current == nullptr)
    {
        current = new EBFSDirectoryInfo;
        current->isRoot = true;
        current->parent = nullptr;
    }
    
    current->isDir = true;
    current->name = name;
    current->size = 0;
    
    DIR* dir;
    struct dirent* entry;
    
    if (!(dir = opendir(path.c_str())))
        return;
    
    while ((entry = readdir(dir)) != NULL)
    {
        if (entry->d_type == DT_DIR)
        {
            std::string newpath = entry->d_name;
            
            if (newpath == ".")
                continue;
            
            if (newpath == "..")
                continue;
            
            EBFSDirectoryInfo* ent = new EBFSDirectoryInfo;
            ent->name = newpath;
            ent->path = path + "/" + newpath;
            ent->isDir = true;
            ent->isRoot = false;
            ent->parent = current;
            
            current->children.push_back(ent);
            current->size += sizeof(EBFSDirectoryEntry) + newpath.size();
            
            fetchTree(path + "/" + newpath, tree, ent, newpath);
        }
        else
        {
            std::string newpath = entry->d_name;
            
            EBFSDirectoryInfo* ent = new EBFSDirectoryInfo;
            ent->name = newpath;
            ent->path = path + "/" + newpath;
            ent->isDir = false;
            ent->isRoot = false;
            ent->parent = current;
            
            auto file = std::fstream(ent->path,
                std::ios::in | std::ios::binary | std::ios::ate);
            ent->size = file.tellg();
            file.close();
            
            current->children.push_back(ent);
            current->size += sizeof(EBFSDirectoryEntry) + newpath.size();
            
            tree.push_back(ent);
        }
    }
    
    closedir(dir);
    tree.push_back(current);
}

EBFS::EBFS(const size_t size, const uint32_t blockSize, const uint32_t groupSize,
        const uint32_t numInodes, const std::string& root)
        : m_size{ size }, m_blockSize{ blockSize }, m_groupSize{ groupSize },
        m_numInodes{ numInodes }, m_root{ root }, m_image{ nullptr }
{
    m_image = new uint8_t[size];
    memset(m_image, 0, size);
}

EBFS::~EBFS()
{
    delete m_image;
}

uint8_t* EBFS::write()
{
    const auto t1 = std::chrono::system_clock::now();
    uint32_t time = std::chrono::duration_cast<std::chrono::seconds>(t1.time_since_epoch()).count();
    
    size_t bitmapSize = m_size / m_blockSize / m_groupSize / 8;
    size_t inodesSize = m_numInodes * sizeof(EBFSInode);
    
    size_t bitmapGroups = (0x400 + bitmapSize) / (m_groupSize * m_blockSize - 16);
    if ((0x400 + bitmapSize) % (m_groupSize * m_blockSize - 16))
        ++bitmapGroups;
    
    size_t inodesGroups = inodesSize / (m_groupSize * m_blockSize - 16);
    if (inodesSize % (m_groupSize * m_blockSize - 16))
        ++inodesGroups;
    
    std::vector<EBFSDirectoryInfo*> tree;
    fetchTree(m_root, tree);
    std::reverse(tree.begin(), tree.end());
    
    uint32_t nextGroup = bitmapGroups + inodesGroups;
    uint32_t rootDirectory = 0;
    uint32_t nextInode = 0;
    
    for (int i = 0; i < tree.size(); ++i)
    {
        if (!tree[i]->isDir)
            continue;
        
        tree[i]->inode = nextInode++;
    }
    --nextInode;
    
    for (int i = 0; i < tree.size(); ++i)
    {
        if (!tree[i]->isDir)
            continue;
        
        if (tree[i]->isRoot)
        {
            rootDirectory = nextGroup;
            tree[i]->inode = 0;
        }
        
        uint32_t dinodeGroup = bitmapGroups + (sizeof(EBFSInode) * tree[i]->inode) / (m_blockSize * m_groupSize - 16);
        uint32_t dinodeOffset = (sizeof(EBFSInode) * tree[i]->inode) % (m_blockSize * m_groupSize - 16) + 16;
        
        EBFSInode dinode;
        memset(&dinode, 0, sizeof(dinode));
        dinode.type = 0x4000 | 0x16D;
        dinode.fileSize = tree[i]->size;
        dinode.lastAccessTime = time;
        dinode.createdTime = time;
        dinode.modifiedTime = time;
        dinode.firstGroup = nextGroup;
        memcpy(&m_image[(dinodeGroup * m_groupSize * m_blockSize) + dinodeOffset], &dinode, sizeof(dinode));
        
        uint32_t offset = 16;
        
        EBFSDirectoryEntry dot;
        memset(&dot, 0, sizeof(dot));
        dot.inode = tree[i]->inode;
        dot.type = 2;
        dot.entrySize = sizeof(EBFSDirectoryEntry) + 2;
        memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset], &dot, sizeof(dot));
        memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset + sizeof(dot)],
            ".", 2);
        offset += sizeof(dot) + 2;
        
        EBFSDirectoryEntry dotdot;
        memset(&dotdot, 0, sizeof(dotdot));
        if (tree[i]->isRoot)
            dotdot.inode = 0;
        else
            dotdot.inode = tree[i]->parent->inode;
        dotdot.type = 2;
        dotdot.entrySize = sizeof(EBFSDirectoryEntry) + 3;
        memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset], &dotdot, sizeof(dotdot));
        memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset + sizeof(dotdot)],
            "..", 3);
        offset += sizeof(dotdot) + 3;
        
        for (int j = 0; j < tree[i]->children.size(); ++j)
        {
            EBFSDirectoryInfo* child = tree[i]->children[j];
            
            if (!child->isDir)
                child->inode = nextInode;
            
            if (offset >= m_blockSize * m_groupSize)
            {
                EBFSGroupHeader dhdr;
                memset(&dhdr, 0, sizeof(dhdr));
                dhdr.type = 0x02;
                dhdr.nextGroup = nextGroup + 1;
                dhdr.crc32 = 0;
                memcpy(&m_image[nextGroup * m_groupSize * m_blockSize], &dhdr, sizeof(dhdr));
                offset = 0;
                ++nextGroup;
            }
            else if (j + 1 >= tree[i]->children.size())
            {
                EBFSGroupHeader dhdr;
                memset(&dhdr, 0, sizeof(dhdr));
                dhdr.type = 0x02;
                dhdr.nextGroup = 0xFFFFFFFF;
                dhdr.crc32 = 0;
                memcpy(&m_image[nextGroup * m_groupSize * m_blockSize], &dhdr, sizeof(dhdr));
            }
            
            EBFSDirectoryEntry dirent;
            memset(&dirent, 0, sizeof(dirent));
            dirent.inode = nextInode;
            if (child->isDir)
                dirent.type = 0x02;
            else
                dirent.type = 0x01;
            dirent.entrySize = sizeof(dirent) + child->name.size();
            memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset], &dirent, sizeof(dirent));
            memcpy(&m_image[nextGroup * m_groupSize * m_blockSize + offset + sizeof(dirent)],
                child->name.c_str(), child->name.size());
            
            offset += sizeof(dirent) + child->name.size();
            ++nextInode;
        }
        ++nextGroup;
        
        for (int j = 0; j < tree[i]->children.size(); ++j)
        {
            EBFSDirectoryInfo* child = tree[i]->children[j];
            
            if (child->isDir)
                continue;
            
            uint32_t inodeGroup = bitmapGroups + (sizeof(EBFSInode) * child->inode) / (m_blockSize * m_groupSize - 16);
            uint32_t inodeOffset = (sizeof(EBFSInode) * child->inode) % (m_blockSize * m_groupSize - 16) + 16;
            
            EBFSInode inode;
            memset(&inode, 0, sizeof(inode));
            inode.type = 0x816D;
            inode.fileSize = child->size;
            inode.lastAccessTime = time;
            inode.createdTime = time;
            inode.modifiedTime = time;
            inode.firstGroup = nextGroup;
            memcpy(&m_image[(inodeGroup * m_groupSize * m_blockSize) + inodeOffset], &inode, sizeof(inode));
            
            auto file = std::fstream(child->path, std::ios::in | std::ios::binary);
            uint8_t* fbuf = new uint8_t[child->size];
            file.read((char*)fbuf, child->size);
            file.close();
            
            uint32_t numGroups = child->size / (m_blockSize * m_groupSize - 16);
            if (child->size % (m_blockSize * m_groupSize - 16))
                ++numGroups;
           
            for (int k = nextGroup; k < nextGroup + numGroups; ++k)
            {
                uint32_t sz = k + 1 >= nextGroup + numGroups ?
                    (child->size % (m_blockSize * m_groupSize - 16)) :
                    m_blockSize * m_groupSize - 16;
                
                uint32_t offsetFile = (k - nextGroup) * (m_blockSize * m_groupSize - 16);
                memcpy(&m_image[k * m_groupSize * m_blockSize + 16], &fbuf[offsetFile], sz);
                
                EBFSGroupHeader fhdr;
                memset(&fhdr, 0, sizeof(fhdr));
                fhdr.type = 0x01;
                if (k + 1 >= nextGroup + numGroups)
                    fhdr.nextGroup = 0xFFFFFFFF;
                else
                    fhdr.nextGroup = k + 1;
                fhdr.crc32 = 0;
                memcpy(&m_image[k * m_groupSize * m_blockSize], &fhdr, sizeof(fhdr));
            }
            
            delete fbuf;
            fbuf = nullptr;
            nextGroup += numGroups;
        }
    }
    
    for (int i = 1 + bitmapGroups; i < 1 + bitmapGroups + inodesGroups; ++i)
    {
        EBFSGroupHeader hdr;
        memset(&hdr, 0, sizeof(hdr));
        hdr.type = 0x04;
        if (i + 1 >= bitmapGroups + inodesGroups)
            hdr.nextGroup = 0xFFFFFFFF;
        else
            hdr.nextGroup = i + 1;
        hdr.crc32 = 0;
        memcpy(&m_image[i * m_groupSize * m_blockSize], &hdr, sizeof(hdr));
    }
    
    for (int i = 1; i < 1 + bitmapGroups; ++i)
    {
        EBFSGroupHeader hdr;
        memset(&hdr, 0, sizeof(hdr));
        hdr.type = 0x04;
        if (i + 1 >= bitmapGroups)
            hdr.nextGroup = 0xFFFFFFFF;
        else
            hdr.nextGroup = i + 1;
        hdr.crc32 = 0;
        memcpy(&m_image[i * m_groupSize * m_blockSize], &hdr, sizeof(hdr));
    }
    
    size_t sz = bitmapSize >= m_blockSize * m_groupSize - 0x400 ? bitmapSize : m_blockSize * m_groupSize - 0x400;
    
    uint8_t* bitmap = new uint8_t[sz];
    memset(bitmap, 0, sz);
    for (int i = 0; i < nextGroup; ++i)
    {
        uint32_t byte = i / 8;
        uint32_t offset = i % 8;
        
        bitmap[byte] |= 0x80 >> offset;
    }
    
    memcpy(&m_image[0x400], bitmap, m_blockSize * m_groupSize - 0x400);
    
    for (int i = 1; i < bitmapGroups; ++i)
    {
        memcpy(&m_image[i * m_groupSize * m_blockSize + 16],
            &bitmap[i * (m_groupSize * m_blockSize - 16)],
            m_groupSize * m_blockSize - 16);
        
        EBFSGroupHeader fhdr;
        memset(&fhdr, 0, sizeof(fhdr));
        fhdr.type = 0x03;
        if (i + 1 >= bitmapGroups)
            fhdr.nextGroup = 0xFFFFFFFF;
        else
            fhdr.nextGroup = i + 1;
        fhdr.crc32 = 0;
        memcpy(&m_image[i * m_groupSize * m_blockSize], &fhdr, sizeof(fhdr));
    }
    
    EBFSSuperblock super;
    memset(&super, 0, sizeof(super));
    
    super.signature = 0xEBF5;
    super.version = 0x0100;
    super.blockSize = m_blockSize;
    super.groupSize = m_groupSize;
    super.freeGroups = m_size / m_blockSize / m_groupSize;
    super.totalInodes = m_numInodes;
    super.freeInodes = m_numInodes;
    super.inodeSize = sizeof(EBFSInode);
    super.lastMountTime = time;
    super.lastWriteTime = time;
    super.rootDirectory = rootDirectory;
    super.inodes = bitmapGroups;
    
    memcpy(&m_image[m_blockSize], &super, sizeof(super));
    
    return m_image;
}