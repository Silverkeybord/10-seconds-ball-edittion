extends StaticBody3D

const BREAK_SOUND := preload("res://sounds/tank_shield_break.WAV")
const POSSIBLE_HIT_SOUNDS := [
	preload("res://sounds/enemy/enemy_hit_1.WAV"),
	preload("res://sounds/enemy/enemy_hit_2.WAV")
]

@export var ball : Node3D
@export var collision_shape : CollisionShape3D
@export var health : int
@export var temp_sound_scene : PackedScene

@onready var player = get_tree().get_first_node_in_group("player")


func check_death() -> void:
	Global.spawn_temp_sound(POSSIBLE_HIT_SOUNDS.pick_random(), temp_sound_scene, position, self)
	
	if health <= 0:
		Global.spawn_temp_sound(BREAK_SOUND, temp_sound_scene, position, self)
		ball.shield = null
		call_deferred("queue_free")
