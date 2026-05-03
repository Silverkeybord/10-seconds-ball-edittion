extends CharacterBody3D

const speed := 80.0
const lifetime := 2.0

var direction := Vector3.ZERO

@export var fade_in_animation : AnimationPlayer


func _ready() -> void:
	if Global.first_person:
		fade_in_animation.play("first_person_spawn_invisiblity")
	await get_tree().create_timer(lifetime).timeout	
	queue_free()


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_meta("enemy"):
		var damage = Global.SHOP_INFO_UPGRADES["damage"]["value"][str(Global.levels["damage"])]
		body.health -= damage
		body.check_death()
		queue_free()
