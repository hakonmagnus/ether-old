# Ether Boot File System

The Ether Boot File System (EBFS) is a very simple file system used by the
Ether operating system during boot time. It is designed to be fast to read
at the expense of roburstness when writing new files and directories.
Therefore, it should be regenerated when it is modified to avoid fragmenting
the system.

## GUID

The GPT type GUID for EBFS is 1B64A89C-0B29-D04A-9535-0C553D8A01C6. This is
the GUID used to identify an EBFS partition on a disk formatted with
GUID Partition Table layout.

## Blocks and Groups

A block is defined to be the logical sector size of the disk. This is usually
512 bytes. Blocks are grouped into block groups. The number of blocks per group
is variable and depends on how the formatting is performed.

## First Block Group

The first block group contains a reserved sector where a boot sector might go,
followed by the superblock at LBA 1. The remaining blocks and the next block
groups contain a bitmap describing which block groups are in use.

### Superblock

The superblock exists at LBA 1 and has the following layout:

| Start  |  End   |  Size  |          Description                            |
|--------|--------|--------|-------------------------------------------------|
| 0x0000 | 0x0001 | 2      | EBFS Signature (0xEBF5 in little-endian)        |
| 0x0002 | 0x0002 | 2      | Version number (0x0100 in little-endian)        |
| 0x0004 | 0x0007 | 4      | Size of a block in bytes                        |
| 0x0008 | 0x000B | 4      | Number of blocks per block group                |
| 0x000C | 0x000F | 4      | Number of unallocated groups                    |
| 0x0010 | 0x0013 | 4      | Total number of inodes                          |
| 0x0014 | 0x0017 | 4      | Number of unallocated inodes                    |
| 0x0018 | 0x001B | 4      | Size of an inode in bytes                       |
| 0x001C | 0x001F | 4      | Last mount time (POSIX)                         |
| 0x0020 | 0x0023 | 4      | Last write time (POSIX)                         |
| 0x0024 | 0x0027 | 4      | Root directory group number                     |
| 0x0028 | 0x002B | 4      | Inodes group number                             |

### Block Group Usage Bitmap

Immediately following the superblock is the group usage bitmap at LBA 2.
The total size of the bitmap in bytes is given by:

BitmapSize = TotalBlocks / BlocksPerGroup / 8

The number of block groups for the bitmap can then be calculated:

BitmapGroups = BitmapSize / (BlockSize * BlocksPerGroup - 16)

If there is a remainder, an extra group is allocated.

The bitmap consists of a series of bits each corresponding to a block group
on the disk, where a bit value of 1 represents a used group and a bit value
of 0 represents a free group.

## Inode Groups

Immediately following the bitmap groups are the inode groups, containing
the inodes of the file system. The total number of inodes depends on the
formatting and is given in the superblock. The total size of the inodes
in bytes is then:

InodesSize = InodeSize * TotalInodes

The same strategy can then be used to find the number of groups taken by
the inode groups.

## Block Group Header

Each block group starts with a 16-byte header. The actual data portion
of the group is then GroupSizeInBytes - 16. The first block group
does not have this header. The header is defined as follows:

| Start  |  End   |  Size  |          Description                            |
|--------|--------|--------|-------------------------------------------------|
| 0x0000 | 0x0000 | 1      | Type byte:<br>  0x00: Unallocated<br>  0x01: File group<br>  0x02: Directory group<br>  0x03: Bitmap group<br>  0x04: Inode group |
| 0x0001 | 0x0001 | 1      | Reserved (0)                                    |
| 0x0002 | 0x0005 | 4      | Next group in series. If this is the last group, this is set to 0xFFFFFFFF |
| 0x0006 | 0x0009 | 4      | Block group CRC32                               |
| 0x000A | 0x000F | 6      | Reserved (0)                                    |

## Inode

An inode contains information about an entity belonging to the file
system. An inode takes on the following format:

| Start  |  End   |  Size  |          Description                            |
|--------|--------|--------|-------------------------------------------------|
| 0x0000 | 0x0001 | 2      | Type and permissions. Bits 0 to 11 use standard<br>POSIX file permissions. Bits 12 to 15 are as follows:<br>  0x1000: FIFO<br>  0x2000: Character device<br>  0x4000: Directory<br>  0x8000: File<br>  0xA000: Symbolic link<br>  0xC000: Unix socket|
| 0x0002 | 0x0003 | 2      | Reserved (0)                                    |
| 0x0004 | 0x0007 | 4      | File size in bytes                              |
| 0x0008 | 0x000B | 4      | Last access time (POSIX)                        |
| 0x000C | 0x000F | 4      | Creation time (POSIX)                           |
| 0x0010 | 0x0013 | 4      | Last modification time (POSIX)                  |
| 0x0014 | 0x0017 | 4      | Group pointer (LBA / BlocksPerGroup)            |

## Directory

A directory consists of directory entries. The superblock has a pointer to the
root directory. A directory entry uses the following format:

| Start  |  End   |  Size  |          Description                            |
|--------|--------|--------|-------------------------------------------------|
| 0x0000 | 0x0003 | 4      | Index of inode                                  |
| 0x0004 | 0x0004 | 1      | Type byte:<br>  0x00: Unallocated<br>  0x01: File<br>  0x02: Directory<br>  0x03: Character device<br>  0x04: Block device<br>  0x05: FIFO<br>  0x06: Socket<br>  0x07: Symbolic link|
| 0x0005 | 0x0005 | 1      | Reserved (0)                                    |
| 0x0006 | 0x0007 | 2      | Length of directory entry in bytes              |
| 0x0008 | 0x0008+N-1| N   | Name of entry encoded using UTF-8               |