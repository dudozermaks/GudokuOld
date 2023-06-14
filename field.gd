extends VBoxContainer

const board_size : int = 9
@warning_ignore("narrowing_conversion")
const sqrt_board_size : int = sqrt(board_size)

signal all_cells_completed

func _ready():
	var cells = get_tree().get_nodes_in_group("cells")
	for cell in cells:
		cell.text_updated.connect(_is_all_cells_completed)

	# string_to_field("417369825632158947958724316825437169791586432346912758289643571573291684164875293")
	# get_tree().call_group("cells", "disable_if_not_empty")
	# get_tree().call_group("cells", "update_text")

#FIXME when loading from file all user cells are small
# possible solution: new string with cells state:
# 0 - disabled
# 1 - normal
# 2 - small
# this method allows use only one string, both contain initial_cells and user_cells
func save_to_file(filename : String = "user://save1.sudoku") -> void:
	# size is 9*9=81
	var initial_cells : String = ""
	# size is 9*9*9=729 (because of pencilmarks)
	var user_cells : String = ""

	for line in range(0, 9):
		for row in range(0, 9):
			var cell : Cell = _get_cell(line, row)
			# if cell is initial
			if cell.disabled:
				initial_cells += cell.get_as_short_string()
				user_cells += "........."
			else:
				initial_cells += "."
				user_cells += cell.get_as_long_string()

	var file := FileAccess.open(filename, FileAccess.WRITE)

	file.store_line(initial_cells)
	file.store_line(user_cells)

	print("Saved to file at: " + file.get_path_absolute())
	

func load_from_file(filename : String = "user://save1.sudoku") -> void:
	var file := FileAccess.open(filename, FileAccess.READ)

	var initial_cells : String = file.get_line()
	var user_cells : String = file.get_line()
	print(initial_cells)
	print(user_cells)

	var error_msg : String = "Can't load file! Path:" + file.get_path_absolute()

	# check data
	if initial_cells.length() != 9*9 or\
		user_cells.length() != 9*9*9:
			print(error_msg)
			print("Wrong string size")
			return
	
	for c in initial_cells:
		if c == ".":
			continue
		if !c.is_valid_int():
			print(error_msg)
			print("String contains foreign characters")
			return


	for line in range(0, 9):
		for row in range(0, 9):
			var cell : Cell = _get_cell(line, row)
			cell.reset()
			var pos_at_string : int = line*9 + row

			if initial_cells[pos_at_string] != ".":
				cell.numbers.push_back(initial_cells[pos_at_string].to_int())
				cell.disabled = true
			else:
				cell.is_small = true
				for i in range(pos_at_string*9, pos_at_string*9 + 9):
					if user_cells[i] != ".":
						cell.numbers.push_back(user_cells[i].to_int())

	init_field()
	print("Loaded file from: " + file.get_path_absolute())


func _get_cell(line : int, row : int) -> Cell:
	return get_node("Line%d/Cell%d" % [line, row])

func _set_focus() -> void:
	for line in range(board_size):
		for row in range(board_size):
			var cell := _get_cell(line, row)
			if cell.numbers.size() == 0:
				cell.grab_focus()
				return


func field_to_string() -> String:
	var result := ""
	for line in range(board_size):
		for row in range(board_size):
			var cell := _get_cell(line, row)
			if cell.numbers.size() != 1:
				result += "0"
			else:
				result += str(cell.numbers[0])

	return result

func string_to_field(string : String) -> void:
	for line in range(board_size):
		for row in range(board_size):
			var cell = _get_cell(line, row)
			cell.reset()
			var num : String = string[line*board_size + row]
			if num != "." and num != "0":
				cell.numbers.push_back(int(num))

func generate_new_field() -> void:
	string_to_field(Globals.sudoku_generator.generate())
	assert(validate() == Globals.VALIDATE.UNSOLVED, "Generated sudoku is wrong! Sudoku: " + field_to_string())
	get_tree().call_group("cells", "disable_if_not_empty")
	init_field()

func init_field():
	get_tree().call_group("cells", "update_text")

	_set_all_cells_neighbors()
	_set_focus()

# CELL NEIGHBORS SETTERS
func _set_all_cells_neighbors() -> void:
	for y in range(0, 9):
		for x in range(0, 9):
			if !_get_cell(y, x).disabled:
				_set_neighbors_for(Vector2i(x, y))

func _set_neighbors_for(cell_pos : Vector2i) -> void:
	var cell := _get_cell(cell_pos.y, cell_pos.x)

	# set cell neighbor to itself
	cell.set_focus_neighbor(SIDE_TOP, cell.get_path())
	cell.set_focus_neighbor(SIDE_BOTTOM, cell.get_path())
	cell.set_focus_neighbor(SIDE_LEFT, cell.get_path())
	cell.set_focus_neighbor(SIDE_RIGHT, cell.get_path())

	for y in range(cell_pos.y - 1, -1, -1):
		if (_set_neighbor_if_possible(cell, Vector2i(cell_pos.x, y), SIDE_TOP)):
			break

	for y in range(cell_pos.y + 1, 9):
		if (_set_neighbor_if_possible(cell, Vector2i(cell_pos.x, y), SIDE_BOTTOM)):
			break;

	for x in range(cell_pos.x - 1, -1, -1):
		if (_set_neighbor_if_possible(cell, Vector2i(x, cell_pos.y), SIDE_LEFT)):
			break;

	for x in range(cell_pos.x + 1, 9):
		if (_set_neighbor_if_possible(cell, Vector2i(x, cell_pos.y), SIDE_RIGHT)):
			break;

func _set_neighbor_if_possible(cell : Cell, neighbor_pos : Vector2i, side : Side) -> bool:
	var neighbor := _get_cell(neighbor_pos.y, neighbor_pos.x)

	if (!neighbor.disabled):
		cell.set_focus_neighbor(side, neighbor.get_path())
		return true
	return false


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

func _is_all_cells_completed():
	var cells = get_tree().get_nodes_in_group("cells")
	for cell in cells:
		if cell.numbers.size() != 1 or cell.is_small:
			return;
	emit_signal("all_cells_completed")
