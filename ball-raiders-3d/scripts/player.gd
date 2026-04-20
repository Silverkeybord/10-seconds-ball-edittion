extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

const RANGE_MIN := 5.0
const RANGE_MAX := 30.0
const RANGE_CURVE := 100.0
const RANGE_THRESHOLD := 10.0

const ENERGY_MIN := 1.0
const ENERGY_MAX := 10.0
const ENERGY_CURVE := 150.0
const ENERGY_THRESHOLD := 20.0

var holding_jump := false

@export var player_light : OmniLight3D


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
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(_delta: float) -> void:
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
	
	print("divider")
	print(player_light.omni_range)
	print(player_light.light_energy)
	print(player_light.light_indirect_energy)
