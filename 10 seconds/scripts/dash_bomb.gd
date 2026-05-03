extends Area3D

@export var animation_player : AnimationPlayer


func _ready() -> void:
	await animation_player.animation_finished
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.has_meta("enemy"):
		body.health -= Global.SHOP_INFO_SKILLS["dash bomb"]["value"][str(Global.levels["dash bomb"])]
		body.check_death()
