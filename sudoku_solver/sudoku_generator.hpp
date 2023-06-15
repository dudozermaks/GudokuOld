#pragma once

#include <godot_cpp/classes/node2d.hpp>
#include "lib/sudokuGen.hpp"

namespace godot {
class SudokuGenerator : public Node2D {
  GDCLASS(SudokuGenerator, Node2D)

  Sudoku generator;
protected:
  static void _bind_methods();
public:
  SudokuGenerator();
  String generate();
  bool is_valid(godot::String puzzle);
  int get_difficulty(godot::String puzzle);
  ~SudokuGenerator();
};
}
