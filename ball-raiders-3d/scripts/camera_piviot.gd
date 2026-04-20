extends Node3D

const MIN_ROT : float = -0.8
const MAX_ROT : float = 0.7

const ZOOM_SPEED := 0.3
const MAX_ZOOM := 10.0
const MIN_ZOOM := 2.0

var pitch := 0.0

@export var sensitivity := 0.003
@export var player : CharacterBody3D
@export var spring_arm : SpringArm3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		player.rotation.y -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, MIN_ROT, MAX_ROT)
		spring_arm.rotation.x = pitch
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length -= ZOOM_SPEED
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length += ZOOM_SPEED
		
		spring_arm.spring_length = clamp(spring_arm.spring_length, 1.0, 10.0)
