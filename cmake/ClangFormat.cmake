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


find_program(CLANG_FORMAT_BIN NAMES clang-format)

if (CLANG_FORMAT_BIN)
    message(STATUS "Found clang-format")

    add_custom_target(
        format
        COMMAND ${CLANG_FORMAT_BIN}
        -style=WebKit
        -i
        ${ETHER_SOURCE_FILES}
        ${ETHER_INCLUDE_FILES}
    )
endif ()
