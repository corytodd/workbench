#include <cstdint>
#include <cstddef>
#include <vector>

#include "lib.hpp"

extern "C" size_t LLVMFuzzerMutate(uint8_t *data, size_t size, size_t max_size);

extern "C" size_t __attribute__((used)) LLVMFuzzerCustomMutator(
        uint8_t *data, size_t size, size_t max_size, unsigned int seed) {

    size = LLVMFuzzerMutate(data, size, max_size);

    // Enforce minimum size of 2 bytes
    if (size < 2) {
        if (max_size < 2) {
            // Can't grow beyond max_size, so just keep current size
            return size;
        }
        size = 2;
    }

    // Fix up checksum: XOR of all bytes except the last
    const uint8_t sof = 0xDB;
    data[0] = sof;
    uint8_t checksum = sof;
    for (size_t i = 1; i < size - 1; ++i) {
        checksum ^= data[i];
    }
    data[size - 1] = checksum;


    return size;
}

extern "C" int __attribute__((used)) LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    std::vector<uint8_t> vec(data, data + size);

    Encoder encoder;
    encoder.encode(vec);

    return 0;
}