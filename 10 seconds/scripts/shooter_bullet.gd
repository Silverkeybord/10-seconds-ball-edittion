extends CharacterBody3D

const MAX_DEDUCTION_POS := Vector2(990, 60)
const MIN_DEDUCTION_POS := Vector2(290, 225)
const COLOR := Color(0.0, 0.318, 0.745)

const SPEED = 50
const BULLET_LIFE = 1.5

var direction : Vector3

@export var damage : float
@export var player : CharacterBody3D
@export var time_deduction_scene : PackedScene


func _ready() -> void:
	var player_distence = global_position.distance_to(player.global_position)
	var time = player_distence / SPEED
	
	var target_pos = (player.global_position + (time * player.velocity))
	direction = (target_pos - global_position).normalized()
	
	await get_tree().create_timer(BULLET_LIFE).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	velocity = direction * SPEED
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		Global.time += damage
		
		var new_deduction = time_deduction_scene.instantiate()
		new_deduction.position = Vector2(
		randf_range(MIN_DEDUCTION_POS.x, MAX_DEDUCTION_POS.x),
		randf_range(MIN_DEDUCTION_POS.y, MAX_DEDUCTION_POS.y)
		)
		new_deduction.color = COLOR
		new_deduction.time_change = damage
		add_sibling(new_deduction)
		
		queue_free()
