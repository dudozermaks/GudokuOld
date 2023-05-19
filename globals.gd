extends Node

var is_pencil_active : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_event):
	if Input.is_action_just_released("pencil_active"):
		is_pencil_active = !is_pencil_active

