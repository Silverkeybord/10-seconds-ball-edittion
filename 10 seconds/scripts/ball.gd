extends CharacterBody3D

const MAX_DEDUCTION_POS := Vector2(990, 60)
const MIN_DEDUCTION_POS := Vector2(290, 225)

const POSSIBLE_HIT_SOUNDS := [
	preload("res://sounds/enemy_hit_1.WAV"),
	preload("res://sounds/enemy_hit_2.WAV")
]
const DEATH_SOUND := preload("res://sounds/enemy_die.WAV")
const JUMP_SOUND := preload("res://sounds/enemy_jump.WAV")

var jumping := false
var can_attack := false
var attack_interval := 1.0

var type_info : Dictionary

@export_group("ball stats")
@export var enum_type : int
@export var string_type : String
@export var speed := 5.0
@export var health := 10
@export var time_reward := 2.5
@export var time_damage := -5
@export var energy_reward := 5

@export_group("in scene exports")
@export_subgroup("general")
@export var attack_timer : Timer
@export var inner_ball : MeshInstance3D
@export var outer_ball : MeshInstance3D
@export var light : OmniLight3D

@export_subgroup("yellow")
@export var jump_timer : Timer

@export_group("out of scene")
@export var time_deduction_scene : PackedScene
@export var temp_sound_scene : PackedScene

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	type_info = Global.ENEMY_INFO[string_type]
	
	inner_ball.set_surface_override_material(0, type_info["inner"])
	outer_ball.set_surface_override_material(0, type_info["outer"])
	light.light_color = type_info["light_color"]
	
	match enum_type:
		Global.ENEMY_ENUMS.RED:
			pass
		Global.ENEMY_ENUMS.YELLOW:
			jump_timer.start()
			health = type_info["health"]
			time_damage = type_info["time_damage"]
			time_reward = type_info["time_reward"]
		Global.ENEMY_ENUMS.CYAN:
			jump_timer.start()
			speed = type_info["speed"]
			health = type_info["health"]
			time_damage = type_info["time_damage"]
			time_reward = type_info["time_reward"]
		Global.ENEMY_ENUMS.ORANGE:
			pass
		Global.ENEMY_ENUMS.BLUE:
			pass
		Global.ENEMY_ENUMS.PURPLE:
			pass
		Global.ENEMY_ENUMS.GREEN:
			pass


func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	look_at(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	
	match enum_type:
		Global.ENEMY_ENUMS.RED:
			pass
			
		Global.ENEMY_ENUMS.YELLOW:
			if speed != type_info["normal_speed"]:
				speed -= type_info["jump_speed_decelleration"] * delta
				
				if speed <= type_info["normal_speed"]:
					speed = type_info["normal_speed"]
			
		Global.ENEMY_ENUMS.CYAN:
			pass
		Global.ENEMY_ENUMS.ORANGE:
			pass
		Global.ENEMY_ENUMS.BLUE:
			pass
		Global.ENEMY_ENUMS.PURPLE:
			pass
		Global.ENEMY_ENUMS.GREEN:
			pass
	
	move_and_slide()


# ATTACKING LOGIC ------------------------------------------------------------
func _on_attack_timer_timeout() -> void:
	if can_attack:
		_spawn_time_deduction(inner_ball.get_surface_override_material(0).albedo_color, 
		time_damage)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		can_attack = true
		_on_attack_timer_timeout()
		attack_timer.start()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player:
		can_attack = false

 
func _spawn_time_deduction(color: Color, val: float) -> void:
	var new_deduction = time_deduction_scene.instantiate()
	new_deduction.position = Vector2(
		randf_range(MIN_DEDUCTION_POS.x, MAX_DEDUCTION_POS.x),
		randf_range(MIN_DEDUCTION_POS.y, MAX_DEDUCTION_POS.y)
	)
	new_deduction.color = color
	new_deduction.time_change = val
	add_sibling(new_deduction)


# HIT CONTROL AND DEATH ------------------------------------------------------
func hit() -> void:
	Global.spawn_temp_sound(POSSIBLE_HIT_SOUNDS.pick_random(), temp_sound_scene, position, self)
	if health <= 0:
		Global.spawn_temp_sound(DEATH_SOUND, temp_sound_scene, position, self)
		_spawn_time_deduction(Color.BLACK, time_reward)
		Global.enemies -= 1
		player.energy += energy_reward
		queue_free()


# YELLOW JUMPING -------------------------------------------------------------
func _on_jump_timer_timeout() -> void:
	if jumping:
		jumping = false
		return
	
	var val = randi_range(1, type_info["random_jump_chance"])
	
	if val == type_info["random_jump_chance"]:
		Global.spawn_temp_sound(JUMP_SOUND, temp_sound_scene, position, self)
		jumping = true
		velocity.y = type_info["jump_strength"]
		speed = type_info["jump_speed_boost"]
