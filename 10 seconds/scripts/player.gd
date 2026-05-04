extends CharacterBody3D

var DASH_DURATION := 0.2
const SLASH := " / "

const SHOOT_SOUND := preload("res://sounds/shoot_sound.WAV")

# light constraintes
const RANGE_MIN := 5.0
const RANGE_MAX := 30.0
const RANGE_CURVE := 100.0
const RANGE_THRESHOLD := 10.0

const ENERGY_MIN := 2.5
const ENERGY_MAX := 10.0
const ENERGY_CURVE := 150.0
const ENERGY_THRESHOLD := 20.0

const TIME_SCALE_ENERGY_COST := 10.0
const MIN_ENERGY_FOR_TIME_SCALE := 10.0

var energy_regen := 1
var dash_speed := 50.0
var reload := 0.5
var jump_velocity := 4.5
var normal_speed := 10.0
var dash_energy_cost := 30

var can_shoot := true
var holding_jump := false

var dash_timer := 0.0
var speed = normal_speed
var energy := 100.0

var dash_bomb_active := true
var changeing_time_scale := false

@export var MAX_ENERGY := 100

@export_group("in scene exports")
@export var player_light : OmniLight3D
@export var dash_sfx_audio_player : AudioStreamPlayer3D
@export var camera_raycast : RayCast3D
@export var time_scale_label : Label

@export_subgroup("ui")
@export var right_energy_bar : ProgressBar
@export var left_energy_bar : ProgressBar
@export var energy_label : Label
@export var dash_toggle_label : Label

@export var ui_animations : AnimationPlayer

@export_group("out of scene")
@export var dash_bomb_scene : PackedScene
@export var bullet_scene : PackedScene
@export var temp_sound_scene : PackedScene


func _ready() -> void:
	_check_upgrades()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_released("jump") and is_on_floor():
		velocity.y = jump_velocity
	

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
		speed == normal_speed and
		energy >= dash_energy_cost):
		
		energy -= dash_energy_cost
		speed = dash_speed
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		dash_timer = DASH_DURATION
		dash_sfx_audio_player.play()
		
		if dash_bomb_active and Global.levels["dash bomb"]:
			_spawn_dash_bomb()
	
	if speed != normal_speed:
		dash_timer -= delta
		
		if dash_timer <= 0:
			speed = normal_speed
			set_collision_layer_value(1, true)
			set_collision_mask_value(1, true)


func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()
	
	if (
		Input.is_action_pressed("dash_bomb_toggle") 
		and not ui_animations.is_playing() 
		and Global.levels["dash bomb"]
		):
		
		dash_bomb_active = not dash_bomb_active
		
		if dash_bomb_active:
			dash_toggle_label.text = "active"
			dash_toggle_label.modulate = Color(0, 1, 0)
		else:
			dash_toggle_label.text = "inactive"
			dash_toggle_label.modulate = Color(1, 0, 0)
			
		# this is something interesting i learnt will you butcher me 
		# idk will you read this probably not
		
		ui_animations.play("toggle_dash_bomb")
	
	
	_time_scale_handeling(delta)
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
	await get_tree().create_timer(reload).timeout
	can_shoot = true


func _energy_generation(delta : float) -> void:
	energy += (energy_regen / (1 / delta)) / Global.time_scale
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


func _check_upgrades() -> void:
	normal_speed = Global.SHOP_INFO_UPGRADES["move speed"]["value"][str(Global.levels["move speed"])]
	reload = Global.SHOP_INFO_UPGRADES["reload"]["value"][str(Global.levels["reload"])]
	energy_regen = Global.SHOP_INFO_UPGRADES["energy regen"]["value"][str(Global.levels["energy regen"])]
	dash_energy_cost = Global.SHOP_INFO_UPGRADES["dash energy reduction"]["value"][str(Global.levels["dash energy reduction"])]
	dash_speed = Global.SHOP_INFO_UPGRADES["dash speed"]["value"][str(Global.levels["dash speed"])]
	jump_velocity = Global.SHOP_INFO_UPGRADES["jump height"]["value"][str(Global.levels["jump height"])]


func _spawn_dash_bomb() -> void:
	energy -= Global.SHOP_INFO_UPGRADES["dash bomb energy"]["value"][str(Global.levels["dash bomb energy"])]
	
	var new_dash_bomb = dash_bomb_scene.instantiate()
	add_sibling(new_dash_bomb)
	new_dash_bomb.global_position = global_position


func _time_scale_handeling(delta : float) -> void:
	if Global.levels["time manipulation"] == 0 or energy < MIN_ENERGY_FOR_TIME_SCALE:
		Global.time_scale = 1
		return
	
	if Input.is_action_pressed("time_acceleration_toggle"):
		changeing_time_scale = true
		time_scale_label.visible = true
	else:
		changeing_time_scale = false
		time_scale_label.visible = false
	
	if Global.time_scale != 1:
		energy -= delta * TIME_SCALE_ENERGY_COST * Global.time_scale
		
