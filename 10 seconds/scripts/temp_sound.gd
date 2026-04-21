extends AudioStreamPlayer3D


func _ready() -> void:
	play()
	await finished
	queue_free()
