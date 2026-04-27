extends PanelContainer

const SURVIVE_FOR_TEXT := "survive for: "
const COST_TEXT := "cost: "
const VALUE_TEXT := "value: "
const MAX_LEVEL_TEXT := "max level"
const RUNTIME_DIFFICULTY_RELATION := 10

@export var upgrade : String

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

var remaining_cost : int
var current_value : float
var next_value : float
var upgrade_info : Dictionary
var description : String


func _ready() -> void:
	await get_tree().process_frame
	upgrade_info = Global.SHOP_INFO_UPGRADES[upgrade]
	required_difficulty = upgrade_info["required_difficulty"]
	
	if upgrade_info.has("description"):
		description = upgrade_info["description"]
		info_button.disabled = false
		info_button.modulate = Color.WHITE
	
	if Global.highest_difficulty >= required_difficulty and locked:
		locked_overlay.visible = false
		locked = false
		exchange_button.disabled = false
	else:
		locked_label.text = (SURVIVE_FOR_TEXT 
							+ str(required_difficulty * RUNTIME_DIFFICULTY_RELATION)
							+ "s")
	
	_update_values()


func _update_values() -> void:
	upgrade_name_label.text = upgrade
	
	if Global.upgrade_levels[upgrade] == upgrade_info["levels"]:
		current_value = upgrade_info["value"][str(Global.upgrade_levels[upgrade])]
		
		cost_label.text = MAX_LEVEL_TEXT
		value_label.text = VALUE_TEXT + str(current_value)
		exchange_button.disabled = true
	else:
		remaining_cost = upgrade_info["cost"][str(Global.upgrade_levels[upgrade])]
		current_value = upgrade_info["value"][str(Global.upgrade_levels[upgrade])]
		next_value = upgrade_info["value"][str(Global.upgrade_levels[upgrade] + 1)]
		
		cost_label.text = COST_TEXT + str(remaining_cost) + " sec"
		value_label.text = VALUE_TEXT + str(current_value) + "  ->  " + str(next_value)


func _on_exchange_pressed() -> void:
	if Global.seconds >= remaining_cost:
		Global.upgrade_levels[upgrade] += 1
		Global.seconds -= remaining_cost
		_update_values()
	else:
		remaining_cost -= Global.seconds
		Global.seconds = 0
		cost_label.text = COST_TEXT + str(remaining_cost) + " sec"


func check_difficulty_unlock() -> void:
	if Global.highest_difficulty >= required_difficulty and locked:
		locked_overlay.visible = false
		locked = false
		exchange_button.disabled = false


func _on_info_button_mouse_entered() -> void:
	if description:
		UI_control.display_description(description, true, upgrade)


func _on_info_button_mouse_exited() -> void:
	if description:
		UI_control.remove_description(true)
