#include "sudoku_generator.hpp"
#include <cstdio>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SudokuGenerator::_bind_methods(){
  ClassDB::bind_method(D_METHOD("generate"), &SudokuGenerator::generate);
}

SudokuGenerator::SudokuGenerator(){
}

String SudokuGenerator::generate(){
  return "";
}
SudokuGenerator::~SudokuGenerator(){}
