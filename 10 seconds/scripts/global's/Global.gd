extends Node

enum ENEMY_ENUMS {
	RED,
	YELLOW,
	GREEN,
	PURPLE,
	CYAN,
	BLUE,
	ORANGE
}

const ENEMY_INFO = {
	# if no value is provided default is used in the ball script
	# speed := 5
	# health := 10
	# time_reward := 2.5
	# time_damage := -5
	# energy_reward := 5
	
	"red" : { # basic
		"inner" : preload("res://textures_and_materials/red/inner.tres"),
		"outer" : preload("res://textures_and_materials/red/outer.tres"),
		"light_color" : Color(0.859, 0.0, 0.0),
	},
	"yellow" : { # jumper
		"inner" : preload("res://textures_and_materials/yellow/inner.tres"),
		"outer" : preload("res://textures_and_materials/yellow/outer.tres"),
		"light_color" : Color(0.925, 0.925, 0.0),
		"health" : 15,
		"time_damage" : -7.5,
		"time_reward" : 4,
		"jump_speed_boost" : 30,
		"jump_strength" : 7,
		"normal_speed" : 5,
		"random_jump_chance" : 4,
		"jump_speed_decelleration" : 30
	},
	"cyan" : { # speed
		"inner" : preload("res://textures_and_materials/cyan/inner.tres"),
		"outer" : preload("res://textures_and_materials/cyan/outer.tres"),
		"light_color" : Color(0.0, 0.824, 0.969),
		"speed" : 20,
		"health" : 5,
		"time_damage" : -10,
		"time_reward" : 5,
	},
	"orange" : { # heavy
		"color" : Color(0.803, 0.324, 0.0, 1.0),
		"speed" : 5,
		"health" : 40,
		"time_damage" : -10,
		"time_reward" : 5,
	},
	"blue" : { # shooter
		"color" : Color(0.0, 0.179, 1.0, 1.0),
		"speed" : 5,
		"health" : 10,
		"time_damage" : 4,
		"time_reward" : 3,
	},
	"purple" : { # time steal
		"color" : Color(0.608, 0.0, 0.851, 1.0),
		"speed" : 5,
		"health" : 10,
		"time_damage" : 4,
		"time_reward" : 3,
	},
	"green" : { # healer
		"color" : Color(0.0, 0.668, 0.184, 1.0),
		"speed" : 5,
		"health" : 10,
		"time_damage" : 4,
		"time_reward" : 3,
	},
}
const DIFFICULTY_SPAWN_RATES = {
	"1" : {
		"red" : 1,
		"yellow" : 0,
		"cyan" : 0,
		"orange" : 0,
		"blue" : 0, 
		"purple" : 0,
		"green" : 0
	},
	"2" : {
		"red" : 0.7,
		"yellow" : 0.3,
		"cyan" : 0,
		"orange" : 0,
		"blue" : 0, 
		"purple" : 0,
		"green" : 0 
	},
	"3" : {
		"red" : 0.3,
		"yellow" : 0.3,
		"cyan" : 0.4,
		"orange" : 0,
		"blue" : 0, 
		"purple" : 0,
		"green" : 0 
	},
	"4" : {
		"red" : 0.3,
		"yellow" : 0.4,
		"cyan" : 0.3,
		"orange" : 0,
		"blue" : 0, 
		"purple" : 0,
		"green" : 0 
	},
}
const ENEMY_TYPES = {
	"red" : ENEMY_ENUMS.RED,
	"yellow" : ENEMY_ENUMS.YELLOW,
	"cyan" : ENEMY_ENUMS.CYAN,
	"orange" : ENEMY_ENUMS.ORANGE,
	"blue" : ENEMY_ENUMS.BLUE,
	"purple" : ENEMY_ENUMS.PURPLE,
	"green" : ENEMY_ENUMS.GREEN
}
const DIFFICULTY_TIME_STEPS = [10, 30, 60]

var enemies := 0
var time := 10.0
var run_time := 0.0
var seconds := 0
var first_person := false
var dead := true
var time_shards := 0
var difficulty := 1
var highest_difficulty := 1


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
