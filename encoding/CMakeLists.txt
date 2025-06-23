set(APP led_encoding)

register_benchmark(NAME ${APP}
        LIB
        src/lib.cpp
        INCLUDE
        src
        TEST
        tests/test_encoding.cpp
)

register_fuzz(NAME ${APP}
        LIB
        src/lib.cpp
        INCLUDE
        src
        FUZZ
        tests/fuzz_encoding.cpp
        FUZZ_DICT
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/magic.dict
)
