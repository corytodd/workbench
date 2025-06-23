if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    message(FATAL_ERROR "Fuzzing requires Clang as the compiler.")
endif()

# Force static runtime (MT) to match Clang's ASan runtime on Windows
if(MSVC OR(WIN32 AND CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
endif()