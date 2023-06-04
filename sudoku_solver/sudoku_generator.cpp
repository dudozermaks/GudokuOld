#include "sudoku_generator.hpp"
#include <cstdio>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SudokuGenerator::_bind_methods(){
  ClassDB::bind_method(D_METHOD("generate"), &SudokuGenerator::generate);
  ClassDB::bind_method(D_METHOD("get_difficulty"), &SudokuGenerator::get_difficulty);
  ClassDB::bind_method(D_METHOD("is_valid", "board"), &SudokuGenerator::is_valid);
}

SudokuGenerator::SudokuGenerator(){
}

String SudokuGenerator::generate(){
  generator.genPuzzle();
  UtilityFunctions::print(("Generated grid: " + generator.getGrid()).c_str());
  return generator.getGrid().c_str();
}

bool SudokuGenerator::is_valid(godot::String board){
  return Sudoku::isRightSolved(board.utf8().get_data(), false);
}

int SudokuGenerator::get_difficulty(){
  return generator.calculateDifficulty();
}

SudokuGenerator::~SudokuGenerator(){}
