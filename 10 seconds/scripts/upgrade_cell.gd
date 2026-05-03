extends PanelContainer

const SURVIVE_FOR_TEXT := "survive for: "
const COST_TEXT := "cost: "
const VALUE_TEXT := "value: "
const MAX_LEVEL_TEXT := "max level"
const RUNTIME_DIFFICULTY_RELATION := 10

@export var upgrade : String
@export var skill : String
@export var cell_name : String

@export var upgrade_name_label : Label
@export var cost_label : Label
@export var value_label : Label
@export var exchange_button : Button
@export var locked_label : Label
@export var locked_overlay : PanelContainer
@export var info_button : Button

@export var UI_control : Control

var locked := true
var required_difficulty : int
var required_skill : String

var cost : int
var current_value : float
var next_value : float
var info : Dictionary
var description : String


func _ready() -> void:
	await get_tree().process_frame
	if upgrade:
		info = Global.SHOP_INFO_UPGRADES[upgrade]
	else:
		info = Global.SHOP_INFO_SKILLS[skill]
	
	if info.has("required_difficulty"):
		required_difficulty = info["required_difficulty"]
	
	if info.has("required_skill"):
		required_skill = info["required_skill"]
		locked_label.text = "buy " + required_skill
	
	if info.has("description"):
		description = info["description"]
		info_button.disabled = false
		info_button.modulate = Color.WHITE
	
	check_difficulty_unlock()
	_update_values()


func _update_values() -> void:
	if upgrade:
		cell_name = upgrade
	else:
		cell_name = skill
	
	upgrade_name_label.text = cell_name
	
	if Global.levels[cell_name] == info["levels"]:
		current_value = info["value"][str(Global.levels[cell_name])]
		
		cost_label.text = MAX_LEVEL_TEXT
		value_label.text = VALUE_TEXT + str(current_value)
		exchange_button.disabled = true
	else:
		cost = info["cost"][str(Global.levels[cell_name])]
		current_value = info["value"][str(Global.levels[cell_name])]
		next_value = info["value"][str(Global.levels[cell_name] + 1)]
		
		cost_label.text = COST_TEXT + str(cost) + " sec"
		value_label.text = VALUE_TEXT + str(current_value) + "  ->  " + str(next_value)


func _on_exchange_pressed() -> void:
	if Global.seconds >= cost:
		Global.seconds -= cost
		Global.levels[cell_name] += 1
		_update_values()
		if skill:
			UI_control._check_upgrades_and_skills()


func check_difficulty_unlock() -> void:
	if required_skill:
		if Global.levels[required_skill] != 0:
			_unlock()
	else:
		if Global.highest_difficulty >= required_difficulty and locked:
			_unlock()
		else:
			locked_label.text = (
				SURVIVE_FOR_TEXT + 
				str(required_difficulty * RUNTIME_DIFFICULTY_RELATION) +
				"s"
				)


func _unlock() -> void:
	locked_overlay.visible = false
	locked = false
	exchange_button.disabled = false


func _on_info_button_mouse_entered() -> void:
	if description:
		if upgrade:
			UI_control.display_description(description, true, upgrade)
		else:
			UI_control.display_description(description, false, upgrade)


func _on_info_button_mouse_exited() -> void:
	if description:
		if upgrade:
			UI_control.remove_description(true)
		else:
			UI_control.remove_description(false)
