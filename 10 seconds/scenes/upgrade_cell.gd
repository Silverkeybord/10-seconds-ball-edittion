extends PanelContainer

@export var upgrade : String
@export var remaining_cost : int
@export var current_value : float
@export var next_value : float

@export var upgrade_name_label : Label
@export var cost_label : Label
@export var value_label : Label
@export var exchange_button : Button

var level := 0



func _ready() -> void:
	upgrade_name_label.text = upgrade
	remaining_cost = Global.SHOP_INFO[upgrade]["1"]


func _on_exchange_pressed() -> void:
	pass # Replace with function body.
