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

const SAVE_PATH := "user://10_seconds_3D.save"
const BASE_STAT_MULT_FACTOR := 10.0

const SHOP_INFO_UPGRADES = {
	"damage" : {
		"cost" : {
			"0" : 20,
			"1" : 30,
			"2" : 50,
			"3" : 75,
			"4" : 120,
			"5" : 200,
		},
		"value" : {
			"0" : 1,
			"1" : 2,
			"2" : 3,
			"3" : 4,
			"4" : 5,
			"5" : 8,
			"6" : 10,
		},
		"levels" : 6,
		"required_difficulty" : 0
	},
	#############################################################################################
	"reload" : {
		"cost" : {
			"0" : 25,
			"1" : 50,
			"2" : 75,
			"3" : 100,
			"4" : 150,
			"5" : 220,
		},
		"value" : {
			"0" : 0.5,
			"1" : 0.4,
			"2" : 0.3,
			"3" : 0.25,
			"4" : 0.2,
			"5" : 0.15,
			"6" : 0.1,
		},
		"levels" : 6,
		"required_difficulty" : 0
	},
	#############################################################################################
	"jump height" : {
		"cost" : {
			"0" : 25,
			"1" : 30,
			"2" : 45,
			"3" : 70,
		},
		"value" : {
			"0" : 4.5,
			"1" : 5,
			"2" : 6,
			"3" : 7,
			"4" : 8,
		},
		"levels" : 4,
		"required_difficulty" : 2
	},
	#############################################################################################
	"move speed" : {
		"cost" : {
			"0" : 20,
			"1" : 40,
			"2" : 60,
		},
		"value" : {
			"0" : 10,
			"1" : 12,
			"2" : 14,
			"3" : 16,
		},
		"levels" : 3,
		"required_difficulty" : 3
	},
	#############################################################################################
	"energy regen" : {
		"cost" : {
			"0" : 20,
			"1" : 30,
			"2" : 50,
			"3" : 80,
			"4" : 120,
		},
		"value" : {
			"0" : 1,
			"1" : 3,
			"2" : 5,
			"3" : 7,
			"4" : 10,
			"5" : 15,
		},
		"levels" : 5,
		"description" : "time spend energy gained",
		"required_difficulty" : 4
	},
	#############################################################################################
	"dash bomb energy" : {
		"cost" : {
			"0" : 20,
			"1" : 30,
			"2" : 40,
			"3" : 50,
			"4" : 60,
		},
		"value" : {
			"0" : 25,
			"1" : 21,
			"2" : 18,
			"3" : 15,
			"4" : 12,
			"5" : 10,
		},
		"levels" : 5,
		"description" : "reduces the energy of using dash bomb",
		"required_skill" : "dash bomb",
	},
	#############################################################################################
	"dash energy reduction" : {
		"cost" : {
			"0" : 20,
			"1" : 30,
			"2" : 50,
			"3" : 80,
			"4" : 120,
		},
		"value" : {
			"0" : 30,
			"1" : 25,
			"2" : 22,
			"3" : 29,
			"4" : 17,
			"5" : 15,
		},
		"levels" : 5,
		"required_difficulty" : 6
	},
	#############################################################################################
	"dash speed" : {
		"cost" : {
			"0" : 60,
			"1" : 80,
			"2" : 100,
			"3" : 120,
		},
		"value" : {
			"0" : 50,
			"1" : 55,
			"2" : 60,
			"3" : 65,
			"4" : 70,
		},
		"levels" : 4,
		"required_difficulty" : 6,
		"description" : "faster = more distance",
	},
	#############################################################################################
	#"gods assist" : {
		#"cost" : {
			#"0" : 50,
			#"1" : 100,
			#"2" : 150,
			#"3" : 200,
			#"4" : 250,
			#"5" : 300,
		#},
		#"value" : {
			#"0" : 10,
			#"1" : 8,
			#"2" : 6,
			#"3" : 5,
			#"4" : 3,
			#"5" : 2,
			#"6" : 1
		#},
		#"levels" : 6,
		#"description" : "your god will help you from time to time, 
						#as your inventment grows he will assist more",
		#"required_difficulty" : 12
	#},
}
const SHOP_INFO_SKILLS = {
	#"ground slam" : {
		#"cost" : {
			#"0" : 20,
			#"1" : 75,
			#"2" : 100,
		#},
		#"value" : {
			#"0" : 0,
			#"1" : 10,
			#"2" : 15,
			#"3" : 20
		#},
		#"levels" : 5,
		#"description" : "when you press (s) you will slam into the ground dealing
		#damage to those around you. depending on the height above the ground you 
		#will deal more damage. upgrading this increases that damage factor 
		#(height / n * ground_slam_damage)" ,
		#"required_difficulty" : 2
	#},
	"dash bomb" : {
		"cost" : {
			"0" : 20,
			"1" : 40,
			"2" : 80,
			"3" : 140,
			"4" : 200,
		},
		"value" : {
			"0" : 0,
			"1" : 10,
			"2" : 15,
			"3" : 20,
			"4" : 25,
			"5" : 30,
		},
		"levels" : 5,
		"description" : "when you dash you spawn a bomb that explodes dealing value damage.
		press 'E' to toggle on and off
		(starting energy cost 25 can be redused. damage is value)",
		"required_difficulty" : 4
	},
	#############################################################################################
	#"time acceleration" : {
		#"cost" : {
			#"0" : 100,
			#"1" : 120,
			#"2" : 160,
			#"3" : 200,
			#"4" : 240,
		#},
		#"value" : {
			#"0" : 0,
			#"1" : 0.2,
			#"2" : 0.4,
			#"3" : 0.6,
			#"4" : 0.8,
			#"5" : 1,
		#},
		#"levels" : 5,
		#"description" : "time starts to bend at your will, faster
						#(right click and move your mouse up and down)",
		#"required_difficulty" : 10
	#},
}
const ENEMY_INFO := {
	"red" : { # basic
		"inner" : preload("res://textures_and_materials/red/inner.tres"),
		"outer" : preload("res://textures_and_materials/red/outer.tres"),
		"light_color" : Color(0.859, 0.0, 0.0),
		"speed" : 5,
		"health" : 10,
		"time_damage" : -5,
		"time_reward" : 2.5,
		"energy_reward" : 5,
	},
	"yellow" : { # jumper
		"inner" : preload("res://textures_and_materials/yellow/inner.tres"),
		"outer" : preload("res://textures_and_materials/yellow/outer.tres"),
		"light_color" : Color(0.925, 0.925, 0.0),
		"speed" : 5,
		"health" : 15,
		"time_damage" : -7.5,
		"time_reward" : 4,
		"energy_reward" : 6,
		
		"jump_speed_boost" : 30,
		"jump_strength" : 7,
		"normal_speed" : 5,
		"random_jump_chance" : 6,
		"jump_speed_deceleration" : 30
	},
	"cyan" : { # speed
		"inner" : preload("res://textures_and_materials/cyan/inner.tres"),
		"outer" : preload("res://textures_and_materials/cyan/outer.tres"),
		"light_color" : Color(0.0, 0.824, 0.969),
		"speed" : 30,
		"health" : 5,
		"time_damage" : -10,
		"time_reward" : 8,
		"energy_reward" : 8,
		
		"jump_speed_boost" : 35,
		"jump_strength" : 5,
		"normal_speed" : 30,
		"random_jump_chance" : 6,
		"jump_speed_deceleration" : 10
	},
	"orange" : { # heavy
		"inner" : preload("res://textures_and_materials/orange/inner.tres"),
		"outer" : preload("res://textures_and_materials/orange/outer.tres"),
		"light_color" : Color(0.929, 0.424, 0.0),
		"speed" : 10,
		"health" : 25,
		"time_damage" : -10,
		"time_reward" : 10,
		"energy_reward" : 8,
		
		"scale" : Vector3(2, 2, 2),
		"shield_health" : 75,
		"omni_range" : 6,
		"charge_speed" : 20
	},
	"blue" : { # shooter
		"inner" : preload("res://textures_and_materials/blue/inner.tres"),
		"outer" : preload("res://textures_and_materials/blue/outer.tres"),
		"light_color" : Color(0.0, 0.318, 0.745),
		"speed" : 8,
		"health" : 10,
		"time_damage" : -10,
		"time_reward" : 8,
		"energy_reward" : 7,
		
		"shoot_interval" : 0.75,
		"shoot_damage" : -2
	},
	"purple" : { # time steal
		"inner" : preload("res://textures_and_materials/purple/inner.tres"),
		"outer" : preload("res://textures_and_materials/purple/outer.tres"),
		"light_color" : Color(0.667, 0.0, 0.812),
		"speed" : 5,
		"health" : 10,
		"time_damage" : -1,
		"time_reward" : 3,
		"energy_reward" : 5,
	},
	"green" : { # healer
		"inner" : preload("res://textures_and_materials/green/inner.tres"),
		"outer" : preload("res://textures_and_materials/green/outer.tres"),
		"light_color" : Color(0.176, 0.71, 0.0),
		"speed" : 5,
		"health" : 10,
		"time_damage" : 4,
		"time_reward" : 3,
		"energy_reward" : 10,
	},
}
const DIFFICULTY_SPAWN_RATES := {
	"0" : {
		"spawn_rates" : {
			"red" : 1,
			"yellow" : 0,
			"cyan" : 0,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 2.5
	},
	"1" : {
		"spawn_rates" : {
			"red" : 1,
			"yellow" : 0,
			"cyan" : 0,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 2.2
	},
	"2" : {
		"spawn_rates" : {
			"red" : 0.9,
			"yellow" : 0.1,
			"cyan" : 0,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 2
	},
	"3" : {
		"spawn_rates" : {
			"red" : 0.7,
			"yellow" : 0.3,
			"cyan" : 0,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.6
	},
	"4" : {
		"spawn_rates" : {
			"red" : 0.5,
			"yellow" : 0.4,
			"cyan" : 0.1,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.6
	},
	"5" : {
		"spawn_rates" : {
			"red" : 0.4,
			"yellow" : 0.3,
			"cyan" : 0.3,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.4
	},
	"6" : {
		"spawn_rates" : {
			"red" : 0.3,
			"yellow" : 0.3,
			"cyan" : 0.4,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.4
	},
	"7" : {
		"spawn_rates" : {
			"red" : 0.2,
			"yellow" : 0.2,
			"cyan" : 0.4,
			"orange" : 0.2,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.4
	},
	"8" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.2,
			"cyan" : 0.4,
			"orange" : 0.3,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.2
	},
	"9" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.3,
			"cyan" : 0.2,
			"orange" : 0.4,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1.1
	},
	"10" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.2,
			"cyan" : 0.2,
			"orange" : 0.2,
			"blue" : 0.3,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 1
	},
	"11" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.2,
			"cyan" : 0,
			"orange" : 0.4,
			"blue" : 0.3,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.8
	},
	"12" : {
		"spawn_rates" : {
			"red" : 0,
			"yellow" : 0.2,
			"cyan" : 0.5,
			"orange" : 0.2,
			"blue" : 0.2,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.6
	},
	"13" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.3,
			"cyan" : 0.2,
			"orange" : 0.2,
			"blue" : 0.2,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.5
	},
	"14" : {
		"spawn_rates" : {
			"red" : 0.3,
			"yellow" : 0.2,
			"cyan" : 0.2,
			"orange" : 0,
			"blue" : 0.3,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.5
	},
	"15" : {
		"spawn_rates" : {
			"red" : 0.1,
			"yellow" : 0.2,
			"cyan" : 0.2,
			"orange" : 0.2,
			"blue" : 0.3,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.5
	},
	"16" : {
		"spawn_rates" : {
			"red" : 0,
			"yellow" : 0.8,
			"cyan" : 0,
			"orange" : 0.2,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.4
	},
	"17" : {
		"spawn_rates" : {
			"red" : 0,
			"yellow" : 0.3,
			"cyan" : 0.3,
			"orange" : 0.2,
			"blue" : 0.2,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.4
	},
	"18" : {
		"spawn_rates" : {
			"red" : 0,
			"yellow" : 0,
			"cyan" : 0.5,
			"orange" : 0,
			"blue" : 0.5,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.3
	},
	"19" : {
		"spawn_rates" : {
			"red" : 1,
			"yellow" : 0,
			"cyan" : 0,
			"orange" : 0,
			"blue" : 0,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.1
	},
	"20" : {
		"spawn_rates" : {
			"red" : 0.2,
			"yellow" : 0.2,
			"cyan" : 0.2,
			"orange" : 0.2,
			"blue" : 0.2,
			"purple" : 0,
			"green" : 0
		},
		"spawn_interval" : 0.2
	},
}
const ENEMY_TYPES := {
	"red" : ENEMY_ENUMS.RED,
	"yellow" : ENEMY_ENUMS.YELLOW,
	"cyan" : ENEMY_ENUMS.CYAN,
	"orange" : ENEMY_ENUMS.ORANGE,
	"blue" : ENEMY_ENUMS.BLUE,
	"purple" : ENEMY_ENUMS.PURPLE,
	"green" : ENEMY_ENUMS.GREEN
}

const HIGHEST_DIFFICULTY := 20

var dead := true
var shop_open := false
var ongoing_run := false
var first_person := false

var enemies := 0
var time := 10.0
var run_time := 0.0
var difficulty := 0
var base_stat_mult := 0.0

# save varibles
var seconds := 0
var highest_difficulty := 0
var shop_unlock_remaining_cost := 20

var unlocked_shop := false

var levels := {
	# upgrades
	"damage" : 0,
	"reload" : 0,
	"jump height" : 0,
	"move speed" : 0,
	"energy regen" : 0,
	"dash energy reduction" : 0,
	"dash speed" : 0,
	"time acceleration" : 0,
	"gods assist" : 0,
	
	# skill upgrades
	"dash bomb energy" : 0,
	
	# skills
	"dash bomb" : 0
}


func spawn_temp_sound(sound : AudioStream, temp_sound_scene : PackedScene, 
	pos : Vector3, origin_node: Node) -> void:
	var new_temp_sound = temp_sound_scene.instantiate()
	new_temp_sound.position = pos
	new_temp_sound.stream = sound
	origin_node.add_sibling(new_temp_sound)


func _lock_mouse_movement() -> void:
	if not ongoing_run:
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unlock_mouse_movement() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var save_data = {
		#currency
		"seconds" : seconds,
		
		#other
		"highest_difficulty" : highest_difficulty,
		
		#shop related
		"shop_unlock_remaining_cost" : shop_unlock_remaining_cost,
		"unlocked_shop" : unlocked_shop
	}
	
	file.store_var(save_data)


func load_game():
	if !FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	
	seconds = data["seconds"]
	
	highest_difficulty = data["highest_difficulty"]
	
	shop_unlock_remaining_cost = data["shop_unlock_remaining_cost"]
	unlocked_shop = data["unlocked_shop"]
