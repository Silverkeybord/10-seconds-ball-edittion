extends Node

var enemies := 0
var time := 10.0


func _lock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unlock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
