extends Button
class_name Cell

var numbers : Array[int] = []

func _ready():
	pass

func _process(delta):
	pass

func _input(event):
	if !has_focus():
		return;
	for i in range(1, 10):
		if Input.is_action_just_released(str(i)):
			if i in numbers:
				numbers.erase(i)
			else:
				numbers.push_back(i)
	if (Input.is_action_pressed("erase")):
		numbers.pop_back()

	_update_text()


func _update_text():
	numbers.sort()
	text = ""

	for i in range(0, numbers.size()):
		text += "%d," % numbers[i]
		if !(i+1) % 3:
			text += "\n"
		else:
			text += " "

	if text.length() >= 2:
		text = text.left(-2)

	if text.length() == 1:
		var big_font_size := theme.get_font_size("big_font_size", "Button")
		add_theme_font_size_override("font_size", big_font_size)
	else:
		remove_theme_font_size_override("font_size")
