extends Node3D

@export var ui : Control

func _process(_delta: float) -> void:
	if Global.time <= 0 and not Global.dead:
		Global.time = 0
		Global.ongoing_run = false
		Global.dead = true
		ui.end_run()
		
		var alive_enemies = get_tree().get_nodes_in_group("enemys")
		for x in alive_enemies:
			x.queue_free()
		
		Global.enemies = 0
	
	var diff = floor(Global.run_time / 10)
	
	if Global.highest_difficulty < diff:
		Global.highest_difficulty = diff
	
	Global.difficulty = diff
