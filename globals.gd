extends Node

enum VALIDATE{
	WRONG_SOLVED,
	RIGHT_SOLVED,
	UNSOLVED
}

var is_pencil_active : bool = false
@onready var sudoku_generator : SudokuGenerator = SudokuGenerator.new()
