extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%StartGameButton.grab_focus()

func _on_start_game_button_up():
	get_tree().change_scene_to_file("res://main.tscn")

