#include "sudoku_generator.hpp"
#include <cstdio>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SudokuGenerator::_bind_methods(){
  ClassDB::bind_method(D_METHOD("generate"), &SudokuGenerator::generate);
}

SudokuGenerator::SudokuGenerator(){
  GeneratorOptions options{};

  options.pencilmark = false;
  options.max_puzzles = 1;

  generator.SetOptions(options);
  generator.InitEmpty();
}
String SudokuGenerator::generate(){
  std::string result = generator.Generate();
  UtilityFunctions::print(("Generated sudoku field: " + result).c_str());
  return result.c_str();
}
SudokuGenerator::~SudokuGenerator(){}
