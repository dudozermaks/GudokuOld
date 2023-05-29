extends Control

var time : float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	_update_pencil_lable()
	Globals.pencil_changed.connect(_update_pencil_lable)

func _process(delta):
	_update_time(delta)

func _update_time(delta : float):
	time += delta
	var minutes := time / 60
	var seconds := fmod(time, 60)
	# var milliseconds := time * 100
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]
	

func _update_pencil_lable():
	%PencilLable.text = "Pencil: "
	if Globals.is_pencil_active:
		%PencilLable.text += "on"
	else:
		%PencilLable.text += "off"

func _on_is_solved_button_button_up():
	var is_solved = %Field.validate()

	if is_solved == Globals.VALIDATE.UNSOLVED:
		%CheckLabel.text = "Unsolved"
		%CheckLabel.add_theme_color_override("font_color", Color.GRAY)

	elif is_solved == Globals.VALIDATE.WRONG_SOLVED:
		%CheckLabel.text = "Solved wrong"
		%CheckLabel.add_theme_color_override("font_color", Color.RED)

	elif is_solved == Globals.VALIDATE.RIGHT_SOLVED:
		%CheckLabel.text = "Solved right"
		%CheckLabel.add_theme_color_override("font_color", Color.GREEN)

	%CheckLabel.visible = true

	var hide_label_timer = get_tree().create_timer(10)
	hide_label_timer.timeout.connect(
		func ():
			%CheckLabel.visible = false
	)

