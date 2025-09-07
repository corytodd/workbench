# Benchmarks

Template repo for benchmarking and fuzzing C code.

## Why

The core work for this repo is found in the `cmake/` directory. These functions are intended to
be reusable for quickly adding bench and fuzz support to a project.

## Build

Requires Clang.

```
# e.g. On Debian using Clang 22
CLANG_VERSION=22
$ update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$CLANG_VERSION$ 100
$ update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANG_VERSION 100
```

```
cmake -B build -S .
cmake --build build
```

## Running

Run the encoding example with:

```
cd build/encoding

# Starting monitoring log file on one terminal
tail -F fuzz_log.txt | grep -oP '(SUMMARY: \S+: \S+|\./crash-.*)'

# Run fuzz harness in another
python3 ../../tools/do_fuzz.py ./fuzz_encoding --dict magic.dict 

# Monitor log file in another
grep -oP '(SUMMARY: \S+: \S+|\./crash-.*)' fuzz_log.txt


# Wait for results
SUMMARY: AddressSanitizer: heap-buffer-overflow
./crash-55f1aba519b74e7e8900e1fed056f69ee6b6706d
SUMMARY: AddressSanitizer: heap-buffer-overflow
./crash-14da56ba93250ca73ce49a032055eb66b881d3d3
SUMMARY: AddressSanitizer: heap-buffer-overflow
./crash-e3097ce0a69f42163db76fb2adf10fb5fab2b5b8
SUMMARY: AddressSanitizer: heap-buffer-overflow
./crash-d846cd9b76ec4a95074edcc5f439379d3fc7bb7d

# Inspect a crash
hexdump -C ./crash-d846cd9b76ec4a95074edcc5f439379d3fc7bb7d 
00000000  db 9b 99 da 66 6f 6f 31  32 90 6f 99              |....foo12.o.|
0000000c
```