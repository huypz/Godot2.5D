extends Control

const Item = preload("res://src/items/Item.tscn")
const LootBag = preload("res://src/loot_bags/LootBag.tscn")

var controls : Array
# SLOT : TEXTURERECT
var slots : Dictionary

# Loot
# SLOT : ITEM_ID
var bag_slots : Dictionary
var current_bag = null

var item_held = null
var item_held_offset : Vector2
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
	process_hud()
	var cursor_pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed("left_click"):
		click(cursor_pos)
	if Input.is_action_just_released("left_click"):
		release(cursor_pos)
	
	# Move item texture around with cursor pos
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_held_offset
		
		
func process_hud():
	# Display player's inventory in HUD slots.
	var player_inventory = player.get_inventory()
	for slot in player_inventory:
		if player_inventory.get(slot) != null and slots.get(slot) == null:
			# Set up TextureRect node for item.
			var item_id = player_inventory.get(slot)
			var item = Items.get_item(item_id)
			var item_image = Item.instance()
			item_image.texture = load(Items.ITEMS[item.get("name")]["icon"])
			add_child(item_image)
			slots[slot] = item_image
			item_image.rect_global_position = slot.rect_global_position + slot.rect_size / 2 - item_image.rect_size / 2
			
	# Display bag content in HUD slots:
	if !bag_slots.empty():
		for slot in bag_slots:
			if bag_slots.get(slot) != null and slots.get(slot) == null:
				var item_id = bag_slots.get(slot)
				var item = Items.get_item(item_id)
				var item_image = Item.instance()
				item_image.texture = load(Items.ITEMS[item.get("name")]["icon"])
				add_child(item_image)
				slots[slot] = item_image
				item_image.rect_global_position = slot.rect_global_position + slot.rect_size / 2 - item_image.rect_size / 2

	
func click(pos):
	var control = get_control_on_pos(pos)
	
	# Check if the control is a slot.
	if control != null and (control is Panel):
		# Drag item
		item_held = slots.get(control)
		if item_held != null:
			item_held_offset = item_held.rect_global_position - pos
			last_slot = control
		
	
func release(pos):
	if item_held == null:
		return
		
	var control = get_control_on_pos(pos)
	
	var player_inventory = player.get_inventory()
	var item_held_id
	
	if last_slot.get_parent() == $Inventory:
		item_held_id = player_inventory.get(last_slot)
	elif last_slot.get_parent() == $LootBase/Loot:
		item_held_id = bag_slots.get(last_slot)
#		current_bag.remove_item(last_slot)
#		bag_slots[last_slot] = null
	
	# If control is null, drop item.
	if control == null:
		item_held.queue_free()
		drop_item(player_inventory.get(last_slot))
		slots[last_slot] = null
		player_inventory[last_slot] = null
	# Check if the slot is empty.
	elif slots.get(control) == null:
		# Move item.
		item_held.rect_global_position = control.rect_global_position + control.rect_size / 2 - item_held.rect_size / 2
		slots[last_slot] = null
		slots[control] = item_held
		item_held = null
		
		# If the item is from player inventory, remove it from inventory.
		if last_slot.get_parent() == $Inventory:
			player_inventory[last_slot] = null
		
		# If the item is from a loot bag, remove it from the bag.
		if last_slot.get_parent() == $LootBase/Loot:
			if current_bag != null:
				current_bag.remove_item(last_slot)
		
		# If the control is from player inventory, insert it.
		if control.get_parent() == $Inventory:
			player_inventory[control] = item_held_id
		
		
	# Swap items if the slot is not empty.
	elif slots.get(control) != null:
		var other_item = slots.get(control)
		other_item.rect_global_position = last_slot.rect_global_position + last_slot.rect_size / 2 - other_item.rect_size / 2
		item_held.rect_global_position = control.rect_global_position + control.rect_size / 2 - item_held.rect_size / 2
		slots[last_slot] = other_item
		slots[control] = item_held
		item_held = null
		
		var last_slot_type = last_slot.get_parent()
		var control_slot_type = control.get_parent()
		
#		# Insert item_held into new slot.
#		if control_slot_type == $Inventory:
#			player_inventory[control] = item_held_id
#		if control_slot_type == $LootBase/Loot:
#			current_bag.insert_item(item_held_id)

		player_inventory[last_slot] = player_inventory.get(control)
		player_inventory[control] = item_held_id
		
	else:
		return_item()


func drop_item(item_id):
	var loot_bag = LootBag.instance()
	get_tree().root.get_node("World").add_child(loot_bag)
	loot_bag.insert_item(item_id)
	loot_bag.global_transform = player.global_transform
	

func return_item():
	item_held.rect_global_position = last_slot.rect_global_position + last_slot.rect_size / 2 - item_held.rect_size / 2
	item_held = null


func get_control_on_pos(pos):
	for control in controls:
		if control.get_global_rect().has_point(pos):
			return control
	return null


func show_loot_bag(area):
	bag_slots = area.get_slots()
	current_bag = area
	$LootBase.show()
	for slot in $LootBase.get_children():
		slot.set_mouse_filter(MOUSE_FILTER_STOP)
		

func hide_loot_bag(area):
	bag_slots.clear()
	current_bag = null
	$LootBase.hide()
	for slot in $LootBase/Loot.get_children():
		if slots.get(slot) != null:
			slots.get(slot).queue_free()
