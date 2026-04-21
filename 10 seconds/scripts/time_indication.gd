extends Control

const TIME_REWARD_COLOR := Color(0.0, 0.893, 0.0, 1.0)
const POSSIBLE_LOST_TIME_SOUNDS = [
	preload("res://sounds/lose_time/lose_time_1.WAV"),
	preload("res://sounds/lose_time/lose_time_2.WAV"),
	preload("res://sounds/lose_time/lose_time_3.WAV"),
	preload("res://sounds/lose_time/lose_time_4.WAV"),
	preload("res://sounds/lose_time/lose_time_5.WAV"),
]
const POSSIBLE_GAIN_TIME_SOUNDS = [
	preload("res://sounds/gain_time/gain_time_1.WAV"),
	preload("res://sounds/gain_time/gain_time_2.WAV"),
	preload("res://sounds/gain_time/gain_time_3.WAV"),
	preload("res://sounds/gain_time/gain_time_4.WAV"),
	preload("res://sounds/gain_time/gain_time_5.WAV"),
]

@export var color := Color(1.0, 1.0, 1.0)
@export var text_scale := 1
@export var time_change : float

@export var audiostream : AudioStreamPlayer
@export var animation_player : AnimationPlayer
@export var text_label : Label


func _ready() -> void:
	Global.time += time_change
	
	if time_change > 0:
		audiostream.stream = POSSIBLE_GAIN_TIME_SOUNDS.pick_random()
		text_label.text = "+" + str(time_change) + "s"
		text_label.modulate = TIME_REWARD_COLOR
	else:
		audiostream.stream = POSSIBLE_LOST_TIME_SOUNDS.pick_random()
		text_label.text = str(time_change) + "s"
		text_label.modulate = color
	audiostream.play()
	
	
	animation_player.play("indication")
	await animation_player.animation_finished
	queue_free()
