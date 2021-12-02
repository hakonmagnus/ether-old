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

set(fatutil_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

set(fatutil_INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/fat.hpp
)

add_executable(fatutil ${fatutil_SOURCES})

# Directories and libraries

target_include_directories(fatutil PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Lists

set(ETHER_SOURCE_FILES ${ETHER_SOURCE_FILES} ${fatutil_SOURCES})
set(ETHER_INCLUDE_FILES ${ETHER_INCLUDE_FILES} ${fatutil_INCLUDES})