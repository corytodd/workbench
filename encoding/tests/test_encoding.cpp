#include "benchmark/benchmark.h"
#include <cstdint>
#include <vector>
#include <random>
#include "../src/lib.hpp"

static constexpr int SEED = 42;

static constexpr int VALUES_SIZE = 1'000'000;

std::vector<uint8_t> generate_random_bytes(std::size_t N) {
    std::vector<uint8_t> data(N);
    std::mt19937 gen(SEED);
    std::uniform_int_distribution<> dist(0, 255);

    for (std::size_t i = 0; i < N; ++i) {
        data[i] = static_cast<uint8_t>(dist(gen));
    }

    return data;
}

static void BM_encode(benchmark::State &state) {
    auto data = generate_random_bytes(VALUES_SIZE);
    Encoder encoder;
    for (auto _: state) {
        auto x = encoder.encode(data);
        benchmark::DoNotOptimize(x);
    }
}

BENCHMARK(BM_encode);

BENCHMARK_MAIN();
