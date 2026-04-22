extends CharacterBody3D

const MAX_ENERGY := 100
const ENERGY_REGEN := 5
const SLASH := " / "

const DASH_ENERGY_COST := 30
const DASH_SPEED := 50.0
const DASH_DURATION := 0.2

const NORMAL_SPEED := 10.0
const JUMP_VELOCITY := 4.5

const SHOOT_SOUND := preload("res://sounds/shoot_sound.WAV")

# light constraintes
const RANGE_MIN := 10.0
const RANGE_MAX := 30.0
const RANGE_CURVE := 100.0
const RANGE_THRESHOLD := 10.0

const ENERGY_MIN := 5.0
const ENERGY_MAX := 10.0
const ENERGY_CURVE := 150.0
const ENERGY_THRESHOLD := 20.0

var holding_jump := false
var dash_timer := 0.0
var speed = NORMAL_SPEED
var can_shoot := true
var energy := 100.0

@export var bullet_scene : PackedScene
@export var temp_sound_scene : PackedScene

@export_group("in scene exports")
@export var spring_arm : SpringArm3D
@export var shoot_cooldown : float = 0.2
@export var player_light : OmniLight3D
@export var dash_sfx_audio_player : AudioStreamPlayer3D
@export var right_energy_bar : ProgressBar
@export var left_energy_bar : ProgressBar
@export var energy_label : Label
@export var camera_raycast : RayCast3D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	if (Input.is_action_just_pressed("dash") and 
		speed == NORMAL_SPEED and
		energy >= DASH_ENERGY_COST):
		
		energy -= DASH_ENERGY_COST
		speed = DASH_SPEED
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		dash_timer = DASH_DURATION
		dash_sfx_audio_player.play()
	
	if speed == DASH_SPEED:
		dash_timer -= delta
		
		if dash_timer <= 0:
			speed = NORMAL_SPEED
			set_collision_layer_value(1, true)
			set_collision_mask_value(1, true)


func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()
	
	_energy_generation(delta)
	_omni_light_scaling()


func _shoot() -> void:
	if Global.dead:
		return
	
	var bullet = bullet_scene.instantiate()
	add_sibling(bullet)
	bullet.global_position = global_position
	
	var target_point : Vector3
	if camera_raycast.is_colliding():
		target_point = camera_raycast.get_collision_point()
	else:
		target_point = (camera_raycast.global_position + 
		(-camera_raycast.global_transform.basis.z * -camera_raycast.target_position.z))
	
	var direction = (target_point - bullet.global_position).normalized()
	bullet.direction = direction
	
	Global.spawn_temp_sound(SHOOT_SOUND, temp_sound_scene, position, self)
	
	can_shoot = false
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


func _energy_generation(delta : float) -> void:
	energy += ENERGY_REGEN / (1 / delta)
	energy = round(clamp(energy, 0, MAX_ENERGY) * 100) / 100
	right_energy_bar.value = energy
	left_energy_bar.value = energy
	energy_label.text = str(energy) + SLASH + str(MAX_ENERGY)


func _omni_light_scaling() -> void:
	var time = Global.time
	
	# Range
	if time <= RANGE_THRESHOLD:
		player_light.omni_range = RANGE_MIN
	else:
		player_light.omni_range = max(RANGE_MIN, RANGE_MAX * 
		(1.0 - exp(-time / RANGE_CURVE)))
	
	# Energy
	if time <= ENERGY_THRESHOLD:
		player_light.light_energy = ENERGY_MIN
	else:
		player_light.light_energy = max(ENERGY_MIN, ENERGY_MAX * 
		(1.0 - exp(-(time - ENERGY_THRESHOLD) / ENERGY_CURVE)))
	
	# Indirect energy
	if time <= ENERGY_THRESHOLD:
		player_light.light_indirect_energy = ENERGY_MIN
	else:
		player_light.light_indirect_energy = max(ENERGY_MIN, ENERGY_MAX * 
		(1.0 - exp(-(time - ENERGY_THRESHOLD) / ENERGY_CURVE)))
