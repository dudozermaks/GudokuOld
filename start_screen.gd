extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%StartGameButton.grab_focus()

func _on_start_game_button_up():
	var main_scene = load("res://main.tscn").instantiate()
	get_tree().get_root().add_child(main_scene)
	main_scene.generate_new_field()

func _on_load_button_up():
	var main_scene = load("res://main.tscn").instantiate()
	get_tree().get_root().add_child(main_scene)
	main_scene.get_node("HBoxContainer/Field").load_from_file()

