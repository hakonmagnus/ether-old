#=============================================================================|
#  _______ _________          _______  _______                                |
#  (  ____ \\__   __/|\     /|(  ____ \(  ____ )                              |
#  | (    \/   ) (   | )   ( || (    \/| (    )|                              |
#  | (__       | |   | (___) || (__    | (____)|    By Hákon Hjaltalín.       |
#  |  __)      | |   |  ___  ||  __)   |     __)    Licensed under MIT.       |
#  | (         | |   | (   ) || (      | (\ (                                 |
#  | (____/\   | |   | )   ( || (____/\| ) \ \__                              |
#  (_______/   )_(   |/     \|(_______/|/   \__/                              |
#=============================================================================|

set(diskutil_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

add_executable(diskutil ${diskutil_SOURCES})

# Directories and libraries

target_link_libraries(diskutil partlib)

# Lists

set(ETHER_SOURCE_FILES ${ETHER_SOURCE_FILES} ${diskutil_SOURCES})
