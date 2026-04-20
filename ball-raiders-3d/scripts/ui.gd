extends Control

const starting_time = 10.0

const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const YELLOW := Color(1.0, 1.0, 0.451, 1.0)
const ORANGE := Color(1.0, 0.647, 0.0, 1.0)
const RED := Color(0.961, 0.0, 0.0, 1.0)

const WHITE_THRESHOLD := 15
const YELLOW_THRESHOLD := 10
const ORANGE_THRESHOLD := 5
const RED_THRESHOLD := 1

@export var time : Label


func _process(delta: float) -> void:
	Global.time = round((Global.time - delta) * 100) / 100
	time.text = str(Global.time)
	
	if Global.time > WHITE_THRESHOLD:
		time.modulate = WHITE
	elif Global.time > YELLOW_THRESHOLD:
		time.modulate = YELLOW
	elif Global.time > ORANGE_THRESHOLD:
		time.modulate = ORANGE
	elif Global.time > RED_THRESHOLD:
		time.modulate = RED
