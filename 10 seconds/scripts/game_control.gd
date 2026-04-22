extends Node3D

@export var ui : Control

func _process(_delta: float) -> void:
	if Global.time <= 0 and not Global.dead:
		Global.time = 0
		Global.dead = true
		ui.end_run()
		
		var alive_enemies = get_tree().get_nodes_in_group("enemys")
		for x in alive_enemies:
			x.queue_free()
	
	var diff := 1
	for x in Global.DIFFICULTY_TIME_STEPS:
		if Global.run_time >= x:
			diff += 1
		else:
			break
	
	Global.difficulty = diff
