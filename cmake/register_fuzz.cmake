# Registers a fuzzing target and its associated configuration.
# This function simplifies the setup of libFuzzer-based fuzz tests,
# including source files, linked libraries, include directories, and
# optional fuzzing assets like corpus and dictionary files.
#
# Arguments:
# NAME         [REQUIRED] Name of the fuzzing target.
#
# LIB          [OPTIONAL] List of libraries to link against.
# These will be passed to target_link_libraries().
#
# INCLUDE      [OPTIONAL] List of include directories.
# These will be passed to target_include_directories().
#
# FUZZ         [OPTIONAL] List of fuzz source files (.cpp).
# Each file will be compiled into a fuzzing executable.
#
# FUZZ_CORPUS  [OPTIONAL] Directory path to the seed corpus for this target.
# Used to bootstrap fuzzing with example inputs.
#
# FUZZ_DICT    [OPTIONAL] Path to a .dict file providing known byte patterns
# that help the fuzzer mutate more intelligently.
#
# Usage:
# register_fuzz(
# NAME encoder_fuzz
# LIB lib.c
# INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/include
# FUZZ tests/fuzz_encoder.cpp
# FUZZ_CORPUS ${CMAKE_CURRENT_SOURCE_DIR}/corpus
# FUZZ_DICT ${CMAKE_CURRENT_SOURCE_DIR}/fuzz.dict
# )
#
# Notes:
# - Requires Clang compiler
# - Requires Release or RelWithDebInfo (no -O0)
# - Requires MT linkage on Windows
function(register_fuzz)
    set(options) # No boolean options
    set(oneValueArgs NAME) # Only NAME takes a single value
    set(multiValueArgs # These can have multiple values
        LIB
        INCLUDE
        FUZZ
        FUZZ_CORPUS
        FUZZ_DICT
    )

    cmake_parse_arguments(RT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # RT_<arg> holds the parsed result
    if(NOT RT_NAME)
        message(FATAL_ERROR "register_test requires NAME parameter.")
    endif()

    message(STATUS "Registering test: ${RT_NAME}")
    message(STATUS "  LIB:         ${RT_LIB}")
    message(STATUS "  INCLUDE:     ${RT_INCLUDE}")
    message(STATUS "  FUZZ:        ${RT_FUZZ}")
    message(STATUS "  FUZZ_CORPUS: ${RT_FUZZ_CORPUS}")
    message(STATUS "  FUZZ_DICT:   ${RT_FUZZ_DICT}")

    # Library
    set(LIB ${RT_NAME}_fuzz)
    add_library(${LIB} ${RT_LIB})
    target_include_directories(${LIB} PUBLIC ${RT_INCLUDE})
    target_compile_options(${LIB} PRIVATE -fsanitize=fuzzer,address)
    target_link_options(${LIB} PRIVATE -fsanitize=fuzzer,address)

    set(FUZZ_ASSETS)

    # Always create a corpus directory so we can store seeds between runs
    set(CORPUS ${CMAKE_CURRENT_BINARY_DIR}/corpus)
    add_custom_target(create_corpus_${RT_NAME} ALL
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CORPUS}"
        COMMENT "Creating fuzz corpus: ${CORPUS}"
    )
    set(FUZZ_ASSETS ${FUZZ_ASSETS} create_corpus_${RT_NAME})

    # Copy over any user-provided seeds
    if(RT_FUZZ_CORPUS)
        add_custom_target(copy_fuzz_corpus_${RT_NAME} ALL
            COMMAND ${CMAKE_COMMAND} -E copy_directory ${RT_FUZZ_CORPUS} ${CORPUS}
            DEPENDS ${RT_FUZZ_CORPUS}
            COMMENT "Copying fuzz corpus seeds"
        )
        set(FUZZ_ASSETS ${FUZZ_ASSETS} copy_fuzz_corpus_${RT_NAME})
    endif(RT_FUZZ_CORPUS)

    # Copy over any user-provided hints in dict file format
    if(RT_FUZZ_DICT)
        add_custom_target(copy_fuzz_dict_${RT_NAME} ALL
            COMMAND ${CMAKE_COMMAND} -E copy ${RT_FUZZ_DICT} ${CMAKE_CURRENT_BINARY_DIR}
            DEPENDS ${RT_FUZZ_DICT}
            COMMENT "Copying fuzz dict"
        )
        set(FUZZ_ASSETS ${FUZZ_ASSETS} copy_fuzz_dict_${RT_NAME})
    endif(RT_FUZZ_DICT)

    # Create an executable for each fuzz test
    foreach(fuzz_file IN LISTS RT_FUZZ)
        get_filename_component(TEST_NAME ${fuzz_file} NAME_WE)
        add_executable(${TEST_NAME} ${fuzz_file})
        target_link_libraries(${TEST_NAME} PRIVATE ${LIB})
        target_compile_options(${TEST_NAME} PRIVATE -fsanitize=fuzzer,address)
        target_link_options(${TEST_NAME} PRIVATE -fsanitize=fuzzer,address)

        foreach(dep_target ${FUZZ_ASSETS})
            if(TARGET ${dep_target})
                add_dependencies(${TEST_NAME} ${dep_target})
            endif()
        endforeach()
    endforeach()
endfunction()