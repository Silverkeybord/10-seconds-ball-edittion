extends Node

const SPAWN_RADIUS := 50.0
const SPAWN_HEIGHT := 2.0
const MIN_RADIUS := 10.0
const MAX_ENEMIES := 50

const ENEMY_CAP := 50

@export var ball_scene : PackedScene
@export var spawn_timer : Timer


func _ready() -> void:
	_on_spawn_timer_timeout()


func _process(_delta: float) -> void:
	Engine.time_scale = Global.time_scale


func _on_spawn_timer_timeout() -> void:
	if Global.enemies >= ENEMY_CAP or Global.dead:
		return
	
	var new_ball = ball_scene.instantiate()
	new_ball.position = random_spawn_pos()
	new_ball.add_to_group("enemys")
	
	var val = randf()
	var add := 0.0
	var type : String
	var probilities = Global.DIFFICULTY_SPAWN_RATES[str(Global.difficulty)]["spawn_rates"]
	for x in probilities:
		add += probilities[x]
		if val <= add:
			type = x
			break
	
	new_ball.string_type = type
	new_ball.enum_type = Global.ENEMY_TYPES[type]
	
	match new_ball.enum_type:
		Global.ENEMY_ENUMS.ORANGE:
			new_ball.scale = Global.ENEMY_INFO[type]["scale"]
	
	add_child(new_ball)
	Global.enemies += 1
	
	spawn_timer.wait_time = Global.DIFFICULTY_SPAWN_RATES[str(Global.difficulty)]["spawn_interval"]


func random_spawn_pos() -> Vector3:
	var angle = randf_range(0, TAU)
	var radius = randf_range(MIN_RADIUS, SPAWN_RADIUS)
	return Vector3(
		cos(angle) * radius,
		SPAWN_HEIGHT,
		sin(angle) * radius
	)
