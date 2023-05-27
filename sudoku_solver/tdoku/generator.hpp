#pragma once
#include "tdoku.h"
#include "ketopt.h"
#include "util.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <limits>
#include <random>
#include <set>
#include <tuple>
#include <vector>

struct GeneratorOptions {
    uint64_t max_puzzles = UINT64_MAX;
    double clue_weight = 1.0;
    double guess_weight = 0.5;
    double random_weight = 1.0;
    int clues_to_drop = 3;
    int num_evals = 10;
    int num_puzzles_in_pool = 500;
    bool display_all = false;
    bool minimize = true;
    bool pencilmark = true;
    int solver = 1;
};

class Generator {
private:
    GeneratorOptions options_;

    Util util_{};
    std::vector<std::pair<double, std::string>> pattern_heap{};
    std::set<std::string> pattern_set{};

    const std::string kInitPencilmark =
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789"
            "123456789123456789123456789123456789123456789123456789123456789123456789123456789";

    const std::string kInitVanilla =
            ".................................................................................";

public:
    explicit Generator(const GeneratorOptions &options);
    explicit Generator();

    void SetOptions(const GeneratorOptions &options);

    void InitEmpty();

    bool HasUniqueSolution(const char *puzzle);

    double MeanLogGuesses(char *puzzle);

    int NumClues(const char *puzzle);

    std::tuple<int, double, double> Evaluate(const char *puzzle);

    void Load(const std::string &pattern_filename);

    std::string Generate();
};
