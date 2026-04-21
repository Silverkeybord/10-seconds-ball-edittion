extends Control

const starting_time = 10.0

const GOLD_BACKGROUND_TIME_SCALE := Vector2(1.4, 1.4)

const GOLD_SHAKE_OFFSET := 18
const PURPLE_SHAKE_OFFSET := 10
const GOLD_ROTATION_OFFET = PI/12
const PURPLE_ROTATION_OFFSET = PI/18


const GOLD := Color(0.909, 0.777, 0.0, 1.0)
const PURPLE := Color(0.941, 0.598, 1.0, 1.0)
const BLUE := Color(0.0, 0.832, 0.998, 1.0)
const GREEN := Color(0.0, 0.967, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)
const YELLOW := Color(0.936, 0.936, 0.0, 1.0)
const ORANGE := Color(1.0, 0.647, 0.0, 1.0)
const RED := Color(0.961, 0.0, 0.0, 1.0)
const DARK_RED := Color(0.4, 0.0, 0.0, 1.0)

const GOLD_THRESHOLD := 1000
const PURPLE_THRESHOLD := 500
const BLUE_THRESHOLD := 250
const GREEN_THRESHOLD := 100
const WHITE_THRESHOLD := 30
const YELLOW_THRESHOLD := 20
const ORANGE_THRESHOLD := 10
const RED_THRESHOLD := 5
const DARK_RED_THRESHOLD := 1

var sfx_stage := 0
var shake_rotation_offset := PURPLE_ROTATION_OFFSET
var shake_offset := PURPLE_SHAKE_OFFSET

@export var time : Label
@export var background_time : Label
@export var alot_of_time_sound: AudioStreamPlayer
@export var end_run_sound: AudioStreamPlayer
@export var crosshair : TextureRect
@export var animation : AnimationPlayer


func _process(delta: float) -> void:
	if not Global.dead:
		Global.time = max(0, round((Global.time - delta) * 100) / 100)
		
	
	time.text = str(Global.time)
	background_time.text = str(Global.time)
	
	_background_time_shake()
	_time_color_changes()


func _time_color_changes() -> void:
	if Global.time > PURPLE_THRESHOLD:
		background_time.visible = true
	else:
		background_time.visible = false
	
	if Global.time > GOLD_THRESHOLD:
		if sfx_stage < 2:
			alot_of_time_sound.play()
		sfx_stage = 2
		time.modulate = GOLD
		background_time.modulate = GOLD
		background_time.scale = GOLD_BACKGROUND_TIME_SCALE
		shake_rotation_offset = GOLD_ROTATION_OFFET
		shake_offset = GOLD_SHAKE_OFFSET
		
	elif Global.time > PURPLE_THRESHOLD:
		if sfx_stage < 1:
			alot_of_time_sound.play()
		sfx_stage = 1
		time.modulate = PURPLE
		background_time.modulate = PURPLE
		background_time.scale = Vector2.ONE
		shake_rotation_offset = PURPLE_ROTATION_OFFSET
		shake_offset = PURPLE_SHAKE_OFFSET
		
	elif Global.time > BLUE_THRESHOLD:
		time.modulate = BLUE
	elif Global.time > GREEN_THRESHOLD:
		time.modulate = GREEN
	elif Global.time > WHITE_THRESHOLD:
		time.modulate = WHITE
	elif Global.time > YELLOW_THRESHOLD:
		time.modulate = YELLOW
	elif Global.time > ORANGE_THRESHOLD:
		time.modulate = ORANGE
	elif Global.time > RED_THRESHOLD:
		time.modulate = RED
	elif Global.time > DARK_RED_THRESHOLD:
		time.modulate = DARK_RED


func _background_time_shake() -> void:
	background_time.position.x = randf_range(-shake_offset, shake_offset)
	background_time.position.y = randf_range(-shake_offset, shake_offset)
	background_time.rotation = randf_range(-shake_rotation_offset, shake_rotation_offset)


func end_run() -> void:
	end_run_sound.play()
	animation.play("end_run")
	await animation.animation_finished
	Global._unlock_mouse_movement()


func _on_leave_pressed() -> void:
	get_tree().quit()


func _on_try_again_pressed() -> void:
	animation.play("new_run")
	Global.time = starting_time
	await animation.animation_finished
	Global._lock_mouse_movement()
	Global.dead = false
	
