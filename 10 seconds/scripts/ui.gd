extends Control

const starting_time = 10.0

const GOLD_BACKGROUND_TIME_SCALE := Vector2(1.4, 1.4)
const SECONDS_TEXT := " seconds"
const COST_TEST := "cost: "

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

@export_group("main visuals")
@export var time : Label
@export var background_time : Label
@export var crosshair : TextureRect
@export var animation : AnimationPlayer

@export_group("end run")
@export var alot_of_time_sound: AudioStreamPlayer
@export var end_run_sound: AudioStreamPlayer
@export var you_survived_time : Label

@export_group("shop")
@export var time_currency : Label
@export var time_exchange : Button
@export var normal_upgrades_vbox : VBoxContainer
@export var skill_unlock_vbox : VBoxContainer
@export var upgrade_cell_scene : PackedScene

@onready var message := preload("res://sounds/you have 10 seconds(1).WAV")


func _ready() -> void:
	animation.play("intro")
	await get_tree().process_frame
	
	for upgrade_type in Global.SHOP_INFO:
		var upgrade_cell = upgrade_cell_scene.instantiate()
		upgrade_cell.upgrade = upgrade_type
		normal_upgrades_vbox.add_child(upgrade_cell)
	
	if Global.unlocked_shop:
		time_exchange.text = "time exchange?"
	else:
		time_exchange.text = COST_TEST + str(Global.shop_unlock_remaining_cost) + SECONDS_TEXT
	
	var intro_message = AudioStreamPlayer.new()
	intro_message.stream = message
	add_sibling(intro_message)
	intro_message.play()
	await intro_message.finished
	intro_message.queue_free()
	
	Global.dead = false


func _process(delta: float) -> void:
	if not Global.dead:
		Global.time = max(0, Global.time - delta)
		Global.run_time += delta
	
	time.text = str(snapped(Global.time, 0.01))
	background_time.text = time.text
	
	time_currency.text = "you have " + str(Global.seconds) + " seconds"
	
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
	Global.seconds += round(Global.run_time)
	you_survived_time.text = str(round(Global.run_time * 10) / 10) + SECONDS_TEXT
	
	animation.play("end_run")
	await animation.animation_finished
	Global._unlock_mouse_movement()
	
	var upgrades = normal_upgrades_vbox.get_children()
	for upgrade in upgrades:
		upgrade.check_difficulty_unlock()


func _on_leave_pressed() -> void:
	if animation.is_playing():
		return
	
	get_tree().quit()


func _on_try_again_pressed() -> void:
	if animation.is_playing():
		return
	
	animation.play("new_run")
	var player = get_tree().get_first_node_in_group("player")
	player.position = Vector3.UP
	player._check_upgrades()
	Global.time = starting_time
	Global.run_time = 0
	Global.ongoing_run = true
	
	await animation.animation_finished
	Global._lock_mouse_movement()
	Global.dead = false


func _on_time_exchange_pressed() -> void:
	if Global.unlocked_shop and not animation.is_playing():
		animation.play("open_shop")
		
	else:
		if Global.seconds >= Global.shop_unlock_remaining_cost:
			Global.seconds -= Global.shop_unlock_remaining_cost
			Global.shop_unlock_remaining_cost = 0
			Global.unlocked_shop = true
			time_exchange.text = "time exchange?"
			
		else:
			Global.shop_unlock_remaining_cost -= Global.seconds
			Global.seconds = 0
			time_exchange.text = COST_TEST + str(Global.shop_unlock_remaining_cost) + SECONDS_TEXT


func _on_close_button_pressed() -> void:
	animation.play("close_shop")
