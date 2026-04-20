extends CharacterBody3D

const GRAVITY_MULT := 1.4

const NORMAL_SPEED : float = 5.0
const RANDOM_JUMP_CHANCE := 10 # 1 in n chance of jumping every second
const JUMP_SPEED := 6.0
const JUMP_SPEED_BOOST := 24.0
const SPEED_BOOST_DECELLERATION := 0.25

var speed := NORMAL_SPEED
var jumping := false

@onready var player = get_tree().get_first_node_in_group("player")


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


func _on_timer_timeout() -> void:
	if jumping:
		return
	
	var val = randi_range(0, RANDOM_JUMP_CHANCE)
	
	if val == RANDOM_JUMP_CHANCE:
		jumping = true
		velocity.y = JUMP_SPEED
		speed = JUMP_SPEED_BOOST


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		Global.time += 5
