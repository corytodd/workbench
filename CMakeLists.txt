cmake_minimum_required(VERSION 3.16)
project(PlaygroundBenchmark LANGUAGES CXX)

# C++17 minimum
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
endif()
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O1 -g")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Custom build types: -DCMAKE_BUILD_TYPE=<Benchmark|Sanitizer|Coverage>
include(BuildTypeBenchmark)
include(BuildTypeSanitizer)
include(BuildTypeCoverage)

# Extensions
include(cmake/setup_fuzz.cmake)
include(cmake/setup_benchmark.cmake)
include(cmake/register_benchmark.cmake)
include(cmake/register_fuzz.cmake)

# Options
option(ENABLE_FUZZING "Enable fuzzing targets" ON)
option(ENABLE_TESTING "Enable testing targets" ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message(STATUS "Testing: ${ENABLE_TESTING}")
message(STATUS "Fuzzing: ${ENABLE_FUZZING}")

# Targets
add_subdirectory(encoding)