extends Node

const SPAWN_RADIUS := 50.0
const SPAWN_HEIGHT := 2.0
const MIN_RADIUS := 10.0
const MAX_ENEMIES := 50

const ENEMY_CAP := 30

@export var ball_scene : PackedScene


func _ready() -> void:
	_on_spawn_timer_timeout()


func _on_spawn_timer_timeout() -> void:
	if Global.enemies >= ENEMY_CAP or Global.dead:
		return
	
	var new_ball = ball_scene.instantiate()
	new_ball.position = random_spawn_pos()
	new_ball.add_to_group("enemys")
	add_child(new_ball)
	Global.enemies += 1


func random_spawn_pos() -> Vector3:
	var angle = randf_range(0, TAU)
	var radius = randf_range(MIN_RADIUS, SPAWN_RADIUS)
	return Vector3(
		cos(angle) * radius,
		SPAWN_HEIGHT,
		sin(angle) * radius
	)
