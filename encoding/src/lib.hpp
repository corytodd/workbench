#pragma once

#include <vector>
#include <cstdint>


class Encoder {
public:
    Encoder() = default;

    ~Encoder() = default;

    /// @brief Encode stream without checking validity
    int encode_unchecked(const std::vector<uint8_t> &stream);

    /// @brief Encode stream
    int encode(const std::vector<uint8_t> &stream);

private:
    std::vector<uint8_t> encoded_;

    [[nodiscard]] static bool is_valid_stream(const std::vector<uint8_t> &stream);
};