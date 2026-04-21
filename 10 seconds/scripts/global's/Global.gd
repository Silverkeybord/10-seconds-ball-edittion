extends Node

var enemies := 0
var time := 10.0
var first_person := false
var dead := false


func spawn_temp_sound(sound : AudioStream, temp_sound_scene : PackedScene, 
	pos : Vector3, origin_node: Node) -> void:
	var new_temp_sound = temp_sound_scene.instantiate()
	new_temp_sound.position = pos
	new_temp_sound.stream = sound
	origin_node.add_sibling(new_temp_sound)


func _lock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unlock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
