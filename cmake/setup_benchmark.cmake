include(CPM)

CPMAddPackage(
    NAME googletest
    GITHUB_REPOSITORY google/googletest
    GIT_TAG v1.17.0
    OPTIONS
        "INSTALL_GTEST OFF"
        "BUILD_GMOCK ON"
)

CPMAddPackage(
    NAME benchmark
    GITHUB_REPOSITORY google/benchmark
    GIT_TAG v1.9.5
    OPTIONS
        "BENCHMARK_ENABLE_TESTING OFF"
        "BENCHMARK_ENABLE_INSTALL OFF"
        "BENCHMARK_ENABLE_GTEST_TESTS OFF"
        # Newer Clang flags __COUNTER__ usage in benchmark.h as -Wc2y-extensions;
        # benchmark builds itself with -Werror by default, turning that into a hard error.
        "BENCHMARK_ENABLE_WERROR OFF"
)
