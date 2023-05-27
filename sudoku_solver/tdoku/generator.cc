#include "generator.hpp"

extern "C" {
size_t OtherSolverMiniSat(const char *input,
                          size_t /*unused_limit*/,
                          uint32_t configuration,
                          char *solution, size_t *num_guesses);
}

extern "C" {
size_t OtherSolverGurobi(const char *input,
                         size_t limit,
                         uint32_t configuration,
                         char *solution, size_t *num_guesses);
}

Generator::Generator(const GeneratorOptions &options) : options_(options) {}
Generator::Generator() {}

void Generator::SetOptions(const GeneratorOptions &options){
  options_ = options;
}

void Generator::InitEmpty() {
    double loss = std::numeric_limits<double>::max();
    for (int i = 0; i < options_.num_puzzles_in_pool; i++) {
        const std::string &initial = options_.pencilmark ? kInitPencilmark : kInitVanilla;
        pattern_heap.emplace_back(make_pair(loss, initial));
    }
    make_heap(pattern_heap.begin(), pattern_heap.end());
}

bool Generator::HasUniqueSolution(const char *puzzle) {
    char solution[81];
    size_t guesses = 0;
    return TdokuSolverDpllTriadSimd(puzzle, 2, 0, solution, &guesses) == 1;
}

double Generator::MeanLogGuesses(char *puzzle) {
    char solution[81];
    double sum_log_guesses = 0.0;
    for (int j = 0; j < options_.num_evals; j++) {
        util_.PermuteSudoku(puzzle, options_.pencilmark);
        size_t guesses = 0;
        if (options_.solver == 1) {
            OtherSolverMiniSat(puzzle, 1, 3, solution, &guesses);
        } else if (options_.solver == 2) {
            std::cout << "Must build with -DGUROBI=on to use gurobi" << std::endl;
            exit(1);
        } else {
            TdokuSolverDpllTriadSimd(puzzle, 1, 0, solution, &guesses);
        }
        sum_log_guesses += log((double) guesses + 1);
    }
    return options_.num_evals == 0 ? 0.0 : sum_log_guesses / options_.num_evals;
}

int Generator::NumClues(const char *puzzle) {
    int num_clues = 0;
    if (options_.pencilmark) {
        // for pencilmark a clue is an elimination
        for (int i = 0; i < 729; i++) {
            if (puzzle[i] == '.') num_clues++;
        }
    } else {
        // for vanilla a clue is a cell placement
        for (int i = 0; i < 81; i++) {
            if (puzzle[i] != '.') num_clues++;
        }
    }
    return num_clues;
}

std::tuple<int, double, double> Generator::Evaluate(const char *puzzle){
    char eval_puzzle[729];
    strncpy(eval_puzzle, puzzle, 729);

    int num_clues = NumClues(eval_puzzle);
    double mean_log_guesses = MeanLogGuesses(eval_puzzle);

    double loss;
    if (HasUniqueSolution(eval_puzzle)) {
        loss = num_clues * options_.clue_weight
               - exp(mean_log_guesses * options_.guess_weight)
               + util_.RandomDouble() * options_.random_weight;
    } else {
        loss = std::numeric_limits<double>::max();
    }
    return std::make_tuple(num_clues, exp(mean_log_guesses), loss);
}

void Generator::Load(const std::string &pattern_filename){
  std::ifstream file;
    file.open(pattern_filename);
    if (file.fail()) {
      std::cout << "Error opening " << pattern_filename << std::endl;
        exit(1);
    }
    std::string line;
    char buffer[729];
    int num_loaded = 0;
    while (getline(file, line)) {
        if (line.length() == 0 || line[0] == '#') {
            continue;
        }
        line = line.substr(0, options_.pencilmark ? 729 : 81);
        strncpy(buffer, line.c_str(), 729);
        double loss = std::get<2>(Evaluate(buffer));
        pattern_heap.emplace_back(make_pair(loss, line));
        pattern_set.insert(line);
        num_loaded++;
    }
    make_heap(pattern_heap.begin(), pattern_heap.end());
}
std::string Generator::Generate(){
    char puzzle[729];

    size_t size = options_.pencilmark ? 729 : 81;
    for (uint64_t i = 0; i < options_.max_puzzles; i++) {
        // draw a puzzle or pattern from the pool
        size_t which = util_.RandomUInt() % pattern_heap.size();
        std::string &pattern = pattern_heap[which].second;
        memcpy(puzzle, pattern.c_str(), size);
        if (size == 81) puzzle[81] = '\0';

        // randomly drop clues to unconstrain
        int dropped = 0;
        for (int j : util_.Permutation(size)) {
            if (dropped == options_.clues_to_drop) {
                break;
            }
            if (puzzle[j] == '.') {
                if (options_.pencilmark) {
                    puzzle[j] = (char) ('1' + (j % 9));
                    dropped++;
                }
            } else {
                if (!options_.pencilmark) {
                    puzzle[j] = '.';
                    dropped++;
                }
            }
        }

        // randomly complete and minimize

        if (options_.clues_to_drop > 0) {
            if (!TdokuConstrain(options_.pencilmark, puzzle)) {
                continue;
            }
            if (options_.minimize) {
                TdokuMinimize(options_.pencilmark, false, puzzle);
            }
        }

        // evaluate difficulty via guess counting
        auto eval_stats = Evaluate(puzzle);
        int num_clues = std::get<0>(eval_stats);
        double geo_mean_guesses = std::get<1>(eval_stats);
        double loss = std::get<2>(eval_stats);

        // skip if the puzzle is a duplicate of one still in the pool
        if (options_.clues_to_drop > 0) {
            if (strncmp(puzzle, pattern.c_str(), 729) == 0) {
                continue;
            }
            if (pattern_set.find(puzzle) != pattern_set.end()) {
                continue;
            }
        }

        if (options_.display_all) {
            // printf("%.729s %d %.1f %.2f\n", puzzle, num_clues, geo_mean_guesses, loss);
        }

        // skip if the puzzle's loss is greater than the highest in the pool
        if (loss > pattern_heap.front().first) {
            continue;
        }

        if (!options_.display_all) {
            // printf("%.729s %d %.1f %.2f\n", puzzle, num_clues, geo_mean_guesses, loss);
        }

        // add the generated puzzle to the pool and kick out the one with highest loss
        pattern_set.insert(puzzle);
        pattern_heap.emplace_back(std::make_pair(loss, puzzle));
        push_heap(pattern_heap.begin(), pattern_heap.end());
        pop_heap(pattern_heap.begin(), pattern_heap.end());
        if (pattern_set.find(pattern_heap.back().second) != pattern_set.end()) {
            pattern_set.erase(pattern_heap.back().second);
        }
        pattern_heap.pop_back();
        return puzzle;
    }
    return "";
}

