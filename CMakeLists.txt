cmake_minimum_required(VERSION 3.16)
project(PlaygroundBenchmark LANGUAGES CXX)

# C++17 minimum
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Extensions
include(cmake/setup_fuzz.cmake)
include(cmake/setup_benchmark.cmake)
include(cmake/register_benchmark.cmake)
include(cmake/register_fuzz.cmake)

# Options
option(ENABLE_FUZZING "Enable fuzzing targets" ON)
option(ENABLE_TESTING "Enable testing targets" ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_BUILD_TYPE RelWithDebInfo)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O1 -g")
message(STATUS "Testing: ${ENABLE_TESTING}")
message(STATUS "Fuzzing: ${ENABLE_FUZZING}")

# Targets
add_subdirectory(encoding)