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

add_subdirectory("${CMAKE_SOURCE_DIR}/extern/googletest" "extern/googletest")

# Advanced

mark_as_advanced(
    BUILD_GMOCK BUILD_GTEST BUILD_SHARED_LIBS
    gmock_build_tests gtest_build_samples gtest_build_tests
    gtest_disable_pthreads gtest_force_shared_crt gtest_hide_internal_symbols
)

# IDE directories

set_target_properties(gtest PROPERTIES FOLDER extern)
set_target_properties(gtest_main PROPERTIES FOLDER extern)
set_target_properties(gmock PROPERTIES FOLDER extern)
set_target_properties(gmock_main PROPERTIES FOLDER extern)

# Test

add_executable(tests
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
)

target_link_libraries(tests gtest gmock gtest_main partlib)
target_include_directories(tests PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

gtest_discover_tests(tests
    WORKING_DIRECTORY ${PROJECT_DIR}
    PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${PROJECT_DIR}"
)

set_target_properties(tests PROPERTIES FOLDER tests)

# Coverage

if (CMAKE_BUILD_TYPE STREQUAL "Coverage")
    include(CodeCoverage)
    setup_target_for_coverage(ether_coverage tests coverage)

    set(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
    set(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
endif ()
