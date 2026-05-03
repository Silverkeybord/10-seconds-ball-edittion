extends CharacterBody3D

const MAX_DEDUCTION_POS := Vector2(990, 60)
const MIN_DEDUCTION_POS := Vector2(290, 225)

const POSSIBLE_HIT_SOUNDS := [
	preload("res://sounds/enemy/enemy_hit_1.WAV"),
	preload("res://sounds/enemy/enemy_hit_2.WAV")
]
const DEATH_SOUND := preload("res://sounds/enemy/enemy_die.WAV")
const JUMP_SOUND := preload("res://sounds/enemy/enemy_jump.WAV")
const SPAWN_SOUND := preload("res://sounds/enemy/enemy_spawn.WAV")

const REMOVE_SHIELD_DISTANCE := 15.0
const SHIELD_Z_OFFSET := -1.75

const SHOOTER_SHOOTING_RANGE := 50.0
const SHOOTER_MOVEMENT_RANGE := 30.0

var jumping := false
var can_attack := false
var attack_interval := 1.0

var shield : StaticBody3D

var type_info : Dictionary

@export_group("ball stats")
@export var enum_type : int
@export var string_type : String
@export var speed : float
@export var health : int
@export var time_reward : float
@export var time_damage : int
@export var energy_reward : int

@export_group("in scene exports")
@export_subgroup("general")
@export var attack_timer : Timer
@export var inner_ball : MeshInstance3D
@export var outer_ball : MeshInstance3D
@export var light : OmniLight3D
@export var spawn_beam : MeshInstance3D

@export_subgroup("jumping")
@export var jump_timer : Timer

@export_subgroup("shooting")
@export var shoot_timer : Timer

@export_group("out of scene")
@export var time_deduction_scene : PackedScene
@export var temp_sound_scene : PackedScene
@export var tank_shield : PackedScene
@export var shooter_bullet : PackedScene

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	Global.spawn_temp_sound(SPAWN_SOUND, temp_sound_scene, position, self)
	
	type_info = Global.ENEMY_INFO[string_type]
	
	inner_ball.set_surface_override_material(0, type_info["inner"])
	outer_ball.set_surface_override_material(0, type_info["outer"])
	spawn_beam.set_surface_override_material(0, type_info["outer"])
	
	light.light_color = type_info["light_color"]
	
	speed = type_info["speed"]
	health = type_info["health"]
	time_damage = type_info["time_damage"]
	time_reward = type_info["time_reward"]
	energy_reward = type_info["energy_reward"]
	
	match enum_type:
		Global.ENEMY_ENUMS.YELLOW:
			jump_timer.start()
			
		Global.ENEMY_ENUMS.CYAN:
			jump_timer.start()
			
		Global.ENEMY_ENUMS.ORANGE:
			shield = tank_shield.instantiate()
			shield.health = type_info["shield_health"]
			shield.position.z = SHIELD_Z_OFFSET
			shield.ball = self
			add_child(shield)
			
			light.omni_range = type_info["omni_range"]
			
		Global.ENEMY_ENUMS.BLUE:
			shoot_timer.wait_time = type_info["shoot_interval"]
		Global.ENEMY_ENUMS.PURPLE:
			pass
		Global.ENEMY_ENUMS.GREEN:
			pass
	
	health = round(health * Global.base_stat_mult)
	time_damage = round(time_damage * Global.base_stat_mult)


func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# this is how you remove the annoying bug when the balls have the same x,z
	
	var direction = (player.global_position - global_position).normalized()
	
	# dot product of 1 or -1 means vectors are parallel (directly above or below)
	# dot is how similar a direction is to another -1 = -180 0 = -90 1 = 0
	if abs(direction.dot(Vector3.UP)) < 0.99:
		look_at(player.global_position)
	
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	match enum_type:
		Global.ENEMY_ENUMS.YELLOW, Global.ENEMY_ENUMS.CYAN:
			if speed != type_info["normal_speed"]:
				speed -= type_info["jump_speed_deceleration"] * delta
				
				if speed <= type_info["normal_speed"]:
					speed = type_info["normal_speed"]
		Global.ENEMY_ENUMS.ORANGE:
			if shield:
				if position.distance_to(player.position) <= REMOVE_SHIELD_DISTANCE:
					shield.visible = false
					shield.collision_shape.disabled = true
					speed = type_info["charge_speed"]
				else:
					shield.visible = true
					shield.collision_shape.disabled = false
					speed = type_info["speed"]
		
		Global.ENEMY_ENUMS.BLUE:
			var player_distance = position.distance_to(player.position)
			if (player_distance <= SHOOTER_SHOOTING_RANGE and 
				shoot_timer.is_stopped()):
				
				shoot_timer.start()
				
			if player_distance > SHOOTER_SHOOTING_RANGE:
				if not shoot_timer.is_stopped():
					shoot_timer.stop()
			
			if player_distance <= SHOOTER_MOVEMENT_RANGE:
				speed = 0
			else:
				speed = type_info["speed"]
			
		Global.ENEMY_ENUMS.PURPLE:
			pass
		Global.ENEMY_ENUMS.GREEN:
			pass
	
	spawn_beam.global_rotation.x = 0
	move_and_slide()


# BASIC ATTACKING LOGIC ------------------------------------------------------
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
func check_death() -> void:
	Global.spawn_temp_sound(POSSIBLE_HIT_SOUNDS.pick_random(), temp_sound_scene, position, self)
	if health <= 0:
		Global.spawn_temp_sound(DEATH_SOUND, temp_sound_scene, position, self)
		_spawn_time_deduction(Color.BLACK, time_reward)
		Global.enemies -= 1
		player.energy += energy_reward
		queue_free()


# YELLOW AND CYAN JUMPING ---------------------------------------------------
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


# BLUE SHOOTING --------------------------------------------------------------
func _on_shoot_timer_timeout() -> void:
	var new_bullet = shooter_bullet.instantiate()
	new_bullet.position = global_position
	new_bullet.player = player
	new_bullet.damage = type_info["shoot_damage"]
	add_sibling(new_bullet)
	
