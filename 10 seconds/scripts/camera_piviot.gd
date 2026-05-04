extends Node3D

const MIN_ROT : float = -0.99
const MAX_ROT : float = 0.99

const ZOOM_SPEED := 0.4
const MAX_ZOOM := 15.0
const MIN_ZOOM := 0.0

const FIRST_PERSON_THRESHOLD := 0.5
const TP_X_CAMERA_OFFSET := 0.75
const TP_Y_CAMERA_OFFSET := 1.1

const time_scale_CHANGE := 0.05

var pitch := 0.0

@export var player : CharacterBody3D
@export var spring_arm : SpringArm3D
@export var sensitivity := 0.003
@export var time_scale_label : Label


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		player.rotation.y -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, MIN_ROT, MAX_ROT)
		spring_arm.rotation.x = pitch
		
	if event is InputEventMouseButton:
		if player.changeing_time_scale:
			_change_time_scale(event)
		else:
			_zoom_in_out(event)
	
	if spring_arm.spring_length <= FIRST_PERSON_THRESHOLD:
		Global.first_person = true
		position.x = 0
		position.y = 0
	else: 
		Global.first_person = false
		position.x = TP_X_CAMERA_OFFSET
		position.y = TP_Y_CAMERA_OFFSET


func _change_time_scale(event : InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		Global.time_scale += time_scale_CHANGE
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		Global.time_scale -= time_scale_CHANGE
	
	var max_time_scale = Global.SHOP_INFO_SKILLS["time manipulation"]["value"][str(Global.levels["time manipulation"])]
	
	Global.time_scale = clamp(Global.time_scale, 1, max_time_scale)
	
	time_scale_label.text = str(Global.time_scale) + "x speed"


func _zoom_in_out(event : InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		spring_arm.spring_length -= ZOOM_SPEED
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		spring_arm.spring_length += ZOOM_SPEED
	
	spring_arm.spring_length = clamp(spring_arm.spring_length, MIN_ZOOM, MAX_ZOOM)
