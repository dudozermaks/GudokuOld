extends VBoxContainer

const board_size : int = 9
@warning_ignore("narrowing_conversion")
const sqrt_board_size : int = sqrt(board_size)

func _ready():
	_generate_with_sudoku_generator()
	_set_focus()

	get_tree().call_group("cells", "disable_if_not_empty")
	get_tree().call_group("cells", "update_text")

func _set_focus():
	for line in range(board_size):
		for row in range(board_size):
			var cell : Cell = get_node("Line%d/Cell%d" % [line, row])
			if cell.numbers.size() == 0:
				cell.grab_focus()
				return


func _field_to_string() -> String:
	var result := ""
	for line in range(board_size):
		for row in range(board_size):
			var cell : Cell = get_node("Line%d/Cell%d" % [line, row])
			if cell.numbers.size() != 1:
				result += "."
			else:
				result += str(cell.numbers[0])

	return result

func _string_to_field(string : String) -> void:
	for line in range(board_size):
		for row in range(board_size):
			var cell : Cell = get_node("Line%d/Cell%d" % [line, row])
			var num : String = string[line*board_size + row]
			if num != ".":
				cell.numbers.clear()
				cell.numbers.push_back(int(num))

func _generate_with_sudoku_generator():
	_string_to_field($SudokuGenerator.generate())
	assert(validate() == Globals.VALIDATE.UNSOLVED, "Generated sudoku is wrong! Sudoku: " + _field_to_string())
	

# GETTERS FOR SHAPES
func _get_square(square_number : int) -> Array[Cell]:
	var cells : Array[Cell] = []
	
	@warning_ignore("integer_division")
	var first_line_number = (square_number / sqrt_board_size) * sqrt_board_size
	var first_cell_number = (square_number % sqrt_board_size) * sqrt_board_size
	
	for line_number in range(first_line_number, first_line_number + sqrt_board_size):
		var line = get_node("Line" + str(line_number))
		for cell_number in range(first_cell_number, first_cell_number + sqrt_board_size):
			cells.push_back(line.get_node("Cell" + str(cell_number)))
	
	return cells

func _get_line(line_number : int) -> Array[Cell]:
	var cells : Array[Cell] = []
	
	var line := get_node("Line" + str(line_number))
	for i in range(0, board_size):
		cells.push_back(line.get_node("Cell" + str(i)))
	
	return cells

func _get_row(row_number : int) -> Array[Cell]:
	var cells : Array[Cell] = []
	
	for i in range(0, board_size):
		var line := get_node("Line" + str(i))
		cells.push_back(line.get_node("Cell" + str(row_number)))
	
	return cells

# VALIDATES
func _is_unsolved() -> bool:
	for i in range(board_size):
		var line := get_node("Line" + str(i))
		for j in range(board_size):
			if line.get_node("Cell" + str(j)).numbers.size() != 1:
				return true
	return false

func _is_valid_set(cell_set : Array[Cell]) -> Globals.VALIDATE:
	var numbers : Array[int] = []
	
	for cell in cell_set:
		if cell.numbers.size() != 1: continue
		if cell.numbers[0] in numbers:
			return Globals.VALIDATE.WRONG_SOLVED
		
		numbers.push_back(cell.numbers[0])
	
	return Globals.VALIDATE.RIGHT_SOLVED

func validate() -> Globals.VALIDATE:
	for i in range(0, board_size):
		if  _is_valid_set(_get_line(i)) == Globals.VALIDATE.WRONG_SOLVED or\
				_is_valid_set(_get_row(i)) == Globals.VALIDATE.WRONG_SOLVED or\
				_is_valid_set(_get_square(i)) == Globals.VALIDATE.WRONG_SOLVED:
					return Globals.VALIDATE.WRONG_SOLVED
	
	if _is_unsolved():
		return Globals.VALIDATE.UNSOLVED
	return Globals.VALIDATE.RIGHT_SOLVED
