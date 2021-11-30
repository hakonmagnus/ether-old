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

find_program(CPPCHECK_BIN NAMES cppcheck)

if (CPPCHECK_BIN)
    message(STATUS "Found cppcheck")

    add_custom_target(
        cppcheck
        COMMAND ${CPPCHECK_BIN}
        --enable=warning,performance,portability,information,missingInclude
        --std=c++20
        --template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
        --verbose
        --quiet
        ${ETHER_SOURCE_FILES}
        ${ETHER_INCLUDE_FILES}
    )
endif ()
