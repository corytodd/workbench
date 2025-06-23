set(BENCHMARK_ENABLE_GTEST_TESTS OFF)
set(INSTALL_GTEST OFF)
set(BUILD_GTEST ON)
set(BUILD_GMOCK ON)

# Dependencies
include(FetchContent)
FetchContent_Declare(
        benchmark
        GIT_REPOSITORY https://github.com/google/benchmark.git
        GIT_TAG eddb0241389718a23a42db6af5f0164b6e0139af # v1.9.4
)
FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG 52eb8108c5bdec04579160ae17225d66034bd723 # v1.17.0
)
FetchContent_MakeAvailable(benchmark googletest)
