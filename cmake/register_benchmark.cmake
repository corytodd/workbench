# Registers a benchmark target and its associated metadata.
# This function is intended to simplify the setup of a benchmark
# with optional test sources, include directories, and linked libraries.
#
# Arguments:
# NAME        [REQUIRED] Name of the benchmark target.
#
# LIB         [OPTIONAL] List of libraries to link against.
# These will be passed to target_link_libraries().
#
# INCLUDE     [OPTIONAL] List of include directories.
# These will be passed to target_include_directories().
#
# TEST        [OPTIONAL] List of source files for the benchmark.
# Typically .cpp or .cc files implementing the benchmark(s).
#
# Usage:
# register_benchmark(
# NAME my_benchmark
# LIB lib.c
# INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/include
# TEST test/my_benchmark.cpp
# )
function(register_benchmark)
    set(options) # No boolean options
    set(oneValueArgs NAME) # Only NAME takes a single value
    set(multiValueArgs # These can have multiple values
        LIB
        INCLUDE
        TEST
    )

    cmake_parse_arguments(RT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # RT_<arg> holds the parsed result
    if(NOT RT_NAME)
        message(FATAL_ERROR "register_test requires NAME parameter.")
    endif()

    message(STATUS "Registering test: ${RT_NAME}")
    message(STATUS "  LIB:         ${RT_LIB}")
    message(STATUS "  INCLUDE:     ${RT_INCLUDE}")
    message(STATUS "  TEST:        ${RT_TEST}")

    # Library
    set(LIB ${RT_NAME}_bench)
    add_library(${LIB} ${RT_LIB})
    target_include_directories(${LIB} PUBLIC ${RT_INCLUDE})

    foreach(test_file IN LISTS RT_TEST)
        get_filename_component(TEST_NAME "${test_file}" NAME_WE)
        add_executable(${TEST_NAME} ${test_file})
        target_link_libraries(${TEST_NAME} PRIVATE benchmark::benchmark ${LIB})
    endforeach()
endfunction()