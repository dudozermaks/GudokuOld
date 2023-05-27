#pragma once

#include "tdoku/generator.hpp"
#include <godot_cpp/classes/node2d.hpp>

namespace godot {
class SudokuGenerator : public Node2D {
  GDCLASS(SudokuGenerator, Node2D)

  Generator generator;
protected:
  static void _bind_methods();
public:
  SudokuGenerator();
  String generate();
  ~SudokuGenerator();
};
}
