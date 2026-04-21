extends CharacterBody3D

const GRAVITY_MULT := 1.4

const NORMAL_SPEED : float = 5.0
const RANDOM_JUMP_CHANCE := 10 # 1 in n chance of jumping every 0.5 seconds
const JUMP_SPEED := 6.0
const JUMP_SPEED_BOOST := 24.0
const SPEED_BOOST_DECELLERATION := 0.25

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

@export var speed := NORMAL_SPEED
@export var time_damage := -4
@export var health := 10
@export var time_reward := 3
@export var energy_reward := 5

@export var time_deduction_scene : PackedScene
@export var temp_sound_scene : PackedScene
@export var attack_timer : Timer
@export var inner_ball : MeshInstance3D
@export var hit_sound : AudioStreamPlayer3D

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	attack_timer.wait_time = attack_interval


func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	look_at(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	look_at(player.global_position)
	
	move_and_slide()
	
	if speed >= NORMAL_SPEED:
		speed -= SPEED_BOOST_DECELLERATION
		
		if speed <= NORMAL_SPEED:
			speed = NORMAL_SPEED


func _on_jump_timer_timeout() -> void:
	if jumping:
		jumping = false
		return
	
	var val = randi_range(1, RANDOM_JUMP_CHANCE)
	
	if val == RANDOM_JUMP_CHANCE:
		Global.spawn_temp_sound(JUMP_SOUND, temp_sound_scene, position, self)
		jumping = true
		velocity.y = JUMP_SPEED
		speed = JUMP_SPEED_BOOST


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
		_spawn_time_deduction(Color(1.0, 1.0, 1.0, 1.0), time_reward)
		Global.enemies -= 1
		player.energy += energy_reward
		queue_free()
