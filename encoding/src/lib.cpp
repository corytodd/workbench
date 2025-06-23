#include "lib.hpp"
#include <string>
#include <vector>
#include <cstdint>

static inline bool should_crash_uaf(const std::vector<uint8_t> &stream) {
    std::string input(reinterpret_cast<const char *>(stream.data()), stream.size());
    return input.find("foo12") != std::string::npos;
}

static inline bool should_crash_oob(const std::vector<uint8_t> &stream) {
    std::string input(reinterpret_cast<const char *>(stream.data()), stream.size());
    return input.find("bar45") != std::string::npos;
}

int Encoder::encode_unchecked(const std::vector<uint8_t> &stream) {

    if (should_crash_uaf(stream)) {
        auto mem = new uint8_t(1);
        // oob write
        std::memcpy(mem, stream.data(), stream.size());
        free(mem);

        // use after free
        mem[0] = mem[1];
    }

    if (should_crash_oob(stream)) {
        // 1 byte oob
        auto x = stream[stream.size()];
        (void) x;
    }

    return 0;
}

int Encoder::encode(const std::vector<uint8_t> &stream) {

    if (!is_valid_stream(stream)) {
        return 1;
    }

    return encode_unchecked(stream);
}

bool Encoder::is_valid_stream(const std::vector<uint8_t> &stream) {
    if (stream.size() < 2) {
        return false;
    }

    const auto data = stream.data();
    if (data[0] != 0xDB) {
        return false;
    }
    const auto expected_crc = data[stream.size() - 1];
    auto actual_crc = data[0];
    for (auto val: std::ranges::subrange(stream.begin() + 1, stream.end() - 1)) {
        actual_crc ^= val;
    }
    return actual_crc == expected_crc;
}