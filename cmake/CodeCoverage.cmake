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

find_program(GCOV_PATH gcov)
find_program(LCOV_PATH lcov)
find_program(GENHTML_PATH genhtml)
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

if (NOT GCOV_PATH)
	message(FATAL_ERROR "gcov not found! Aborting...")
endif ()

if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
	if ("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
		message(FATAL_ERROR "Clang version must be 3.0.0 or greater! Aborting...")
	endif ()
elseif (NOT CMAKE_COMPILER_IS_GNUCXX)
	message(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
endif ()

set(CMAKE_CXX_FLAGS_COVERAGE
	"-g -O0 --coverage -fprofile-arcs -ftest-coverage"
	CACHE STRING "Flags used by the C++ compiler during coverage builds."
	FORCE
)

set(CMAKE_C_FLAGS_COVERAGE
	"-g -O0 --coverage -fprofile-arcs -ftest-coverage"
	CACHE STRING "Flags used by the C compiler during coverage builds."
	FORCE
)

set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
	""
	CACHE STRING "Flags used for linking binaries during coverage builds."
	FORCE
)

set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
	""
	CACHE STRING "Flags used by the shared libraries linnker during coverage builds."
	FORCE
)

mark_as_advanced(
	CMAKE_CXX_FLAGS_COVERAGE
	CMAKE_C_FLAGS_COVERAGE
	CMAKE_EXE_LINKER_FLAGS_COVERAGE
	CMAKE_SHARED_LINKER_FLAGS_COVERAGE
)

if (NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
	message(WARNING "Code coverage results with an optimized (non-Debug) build may be misleaDING")
endif ()

function(setup_target_for_coverage _targetname _testrunner _outputname)
	if (NOT LCOV_PATH)
		message(FATAL_ERROR "lcov not found! Aborting...")
	endif ()

	if (NOT GENHTML_PATH)
		message(FATAL_ERROR "genhtml not found! Aborting...")
	endif ()

	set(coverage_info "${CMAKE_BINARY_DIR}/${_outputname}.info")
	set(coverage_cleaned "${coverage_info}.cleaned")

	separate_arguments(test_command UNIX_COMMAND "${_testrunner}")

	add_custom_target(${_targetname}
		${LCOV_PATH} --directory . --zerocounters

		COMMAND ${test_command} ${ARGV3}
		COMMAND lcov --version
		COMMAND gcov --version
		COMMAND g++ --version

		COMMAND ${LCOV_PATH} --directory . --base-directory . --capture --output-file coverage.info
		COMMAND ${LCOV_PATH} --remove coverage.info '/usr*' '*/tests/*' '*/extern/*' -o coverage.info

		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
	)
endfunction ()
