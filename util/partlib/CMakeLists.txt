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

set(partlib_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Image.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CRC32.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GUID.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/EBFS.cpp
)

set(partlib_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/partlib/Image.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/partlib/GPT.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/partlib/CRC32.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/partlib/GUID.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/partlib/EBFS.hpp
)

add_library(partlib STATIC ${partlib_SOURCES})

# Directories and libraries

target_include_directories(partlib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Lists

set(ETHER_SOURCE_FILES ${ETHER_SOURCE_FILES} ${partlib_SOURCES} PARENT_SCOPE)
set(ETHER_INCLUDE_FILES ${ETHER_INCLUDE_FILES} ${partlib_INCLUDES} PARENT_SCOPE)
