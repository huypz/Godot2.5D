extends Control

var controls : Array
var slots : Dictionary

var item_held = null
var item_held_offset : float
var last_slot = null

onready var player = get_tree().root.get_node("World/Player")


func _ready():
	# Get equipment slots
	for slot in $Equipment.get_children():
		controls.append(slot)
	# Get inventory slots
	for slot in $Inventory.get_children():
		controls.append(slot)
	# Get loot slots:
	for slot in $LootBase/Loot.get_children():
		controls.append(slot)


func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	
	
	if Input.is_action_just_pressed("left_click"):
		click(cursor_pos)
		
	# Move item texture around with cursor pos
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_held_offset
		
		
func process_hud():
	var player_inventory = player.get_inventory()

		
func click(pos):
	var control = get_control_on_pos(pos)
	
	# Check if the control is a slot.
	if control != null and (control is Panel):
		# Retrieve item from slot.
		item_held = slots.get(control)
		if item_held != null:
			item_held_offset = item_held.rect_global_position - pos
			last_slot = control
		
	

func get_control_on_pos(pos):
	for control in controls:
		if control.get_global_rect().has_point(pos):
			return control
	return null
