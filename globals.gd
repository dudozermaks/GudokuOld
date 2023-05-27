extends Node

enum VALIDATE{
	WRONG_SOLVED,
	RIGHT_SOLVED,
	UNSOLVED
}

signal pencil_changed
var is_pencil_active : bool = false

func _input(_event):
	if Input.is_action_just_released("pencil_active"):
		is_pencil_active = !is_pencil_active
		emit_signal("pencil_changed")

