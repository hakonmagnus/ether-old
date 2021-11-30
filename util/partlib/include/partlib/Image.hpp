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

using std::size_t;

/**
 * \defgroup partlib Partition library
 * This is the library containing classes and functionality
 * for generating a GPT partitioned hard drive image.
 * @{
 */

/**
 * Hard drive image class
 */
class Image
{
public:
    /**
     * Constructor
     * \param size Size of image in bytes
     * \param mbr MBR filename
     */
    Image(const size_t size, const std::string& mbr, const std::string& fat12bs, const std::string& espImage);

    /**
     * Destructor
     */
    ~Image();

    /**
     * Write file
     * \param path File path to write
     * \return True on success
     */
    bool write(const std::string& path);

private:
    /**
     * Size of image
     */
    size_t m_size;

    /**
     * Hard drive image
     */
    uint8_t* m_image;

    /**
     * MBR filename
     */
    std::string m_mbr;

    /**
     * FAT12 boot sector filename
     */
    std::string m_fat12bs;

    /**
     * EFI system partition image path
     */
    std::string m_espImage;
};

/**
 * @}
 */

