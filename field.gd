extends VBoxContainer 

enum VALIDATE{
	WRONG_SOLVED,
	RIGHT_SOLVED,
	UNSOLVED
}

const board_size : int = 9
@warning_ignore("narrowing_conversion")
const square_size : int = sqrt(board_size)

func _ready():
	get_node("Line0/Cell0").grab_focus()
	
	_fill_field_diagonal()
	
	_fill_field(0, square_size)
	
	get_tree().call_group("cells", "update_text")
	
	print(_validate())

# FILLERS

# as it is, you can fill one diagonal's squares randomly and it 100% would be valid sudoku
func _fill_field_diagonal() -> void:
	for i in range(0, board_size, square_size + 1):
		var numbers = range(1, board_size+1)
		numbers.shuffle()
		var cells := _get_square(i)
		for cell in cells:
			cell.numbers.push_back(numbers.back())
			numbers.pop_back()

func _fill_field(line : int, row : int) -> bool:
	# if we reached the end
	if line == board_size - 1 and row == board_size:
		return true
	
	# if we reached the end of a row
	if row == board_size:
		line += 1
		row = 0
	
	var cell : Cell = get_node("Line%d/Cell%d" % [line, row])
	if cell.numbers.size() != 0:
		return _fill_field(line, row + 1)
	
	for num in range(1, board_size + 1):
		cell.numbers.push_back(num)
		if _validate_for_one_cell(line, row):
			if _fill_field(line, row + 1):
				return true
		cell.numbers.clear()
	
	# No valid value was found, so backtrack
	return false
	
# GETTERS FOR SHAPES
func _get_square(square_number : int) -> Array[Cell]:
	var cells : Array[Cell] = []
	
	@warning_ignore("integer_division")
	var first_line_number = (square_number / square_size) * square_size
	var first_cell_number = (square_number % square_size) * square_size
	
	for line_number in range(first_line_number, first_line_number + square_size):
		var line = get_node("Line" + str(line_number))
		for cell_number in range(first_cell_number, first_cell_number + square_size):
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
	for i in range(0, board_size):
		var line := get_node("Line" + str(i))
		for j in range(0, board_size):
			if line.get_node("Cell" + str(j)).numbers.size() != 1:
				return true
	return false

func _is_valid_set(cell_set : Array[Cell]) -> VALIDATE:
	var numbers : Array[int] = []
	
	for cell in cell_set:
		if cell.numbers.size() != 1: continue
		if cell.numbers[0] in numbers:
			return VALIDATE.WRONG_SOLVED
		
		numbers.push_back(cell.numbers[0])
	
	return VALIDATE.RIGHT_SOLVED

func _validate() -> VALIDATE:
	for i in range(0, board_size):
		if  _is_valid_set(_get_line(i)) == VALIDATE.WRONG_SOLVED or\
				_is_valid_set(_get_row(i)) == VALIDATE.WRONG_SOLVED or\
				_is_valid_set(_get_square(i)) == VALIDATE.WRONG_SOLVED:
					return VALIDATE.WRONG_SOLVED
	
	if _is_unsolved():
		return VALIDATE.UNSOLVED
	return VALIDATE.RIGHT_SOLVED

func _validate_for_one_cell(line : int, row : int) -> bool:
	@warning_ignore("integer_division")
	var square_number = row / 3 + (line / 3) * 3
	if  _is_valid_set(_get_line(line)) == VALIDATE.WRONG_SOLVED or\
			_is_valid_set(_get_row(row)) == VALIDATE.WRONG_SOLVED or\
			_is_valid_set(_get_square(square_number)) == VALIDATE.WRONG_SOLVED:
				return false
	return true
