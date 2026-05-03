extends Area3D

const EXPLOSTION_SOUND = preload("res://sounds/dash_bomb_explosion.WAV")

@export var animation_player : AnimationPlayer
@export var temp_sound_scene : PackedScene


func _ready() -> void:
	Global.spawn_temp_sound(EXPLOSTION_SOUND, temp_sound_scene, global_position, self)
	await animation_player.animation_finished
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.has_meta("enemy"):
		body.health -= Global.SHOP_INFO_SKILLS["dash bomb"]["value"][str(Global.levels["dash bomb"])]
		body.check_death()
