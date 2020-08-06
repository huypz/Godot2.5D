extends Control

const Item = preload("res://src/items/Item.tscn")
const LootBag = preload("res://src/loot_bags/LootBag.tscn")

var controls : Array
# SLOT : TEXTURERECT
var slots : Dictionary

# Player
var player_inventory
var player_equipment

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
		
	$LootBase.hide()


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
	# Get fresh data from player.
	player_inventory = player.get_inventory()
	player_equipment = player.get_equipment()
	if current_bag != null:
		bag_slots = current_bag.get_slots()
	
	
	# Display player's inventory in HUD slots.
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
				
	# Display equipment in HUD slots.
	for slot in player_equipment:
		if player_equipment.get(slot) != null and slots.get(slot) == null:
			var item_id = player_equipment.get(slot)
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
			move_child(item_held, get_child_count())
		
	
func release(pos):
	if item_held == null:
		return
		
	var control = get_control_on_pos(pos)
	var item_held_id = get_item_id_from_slot(last_slot)
	
	# If released on hidden loot slots, return item:
	if control != null and get_slot_type(control) == "Loot" and current_bag == null:
		return_item()
		return
			
	# If mouse cursor is not on HUD, drop item.
	if !$Base.get_global_rect().has_point(pos):
		drop_item(item_held_id, get_slot_type(last_slot))
		
	elif control == null:
		return_item()
		
	# Check if the slot is empty, then move item.
	elif slots.get(control) == null:
		# Check for valid equipment slot.
		if get_slot_type(control) == "Equipment":
			if !item_has_slot_type(item_held_id) and control.name != get_item_slot_type(item_held_id):
				return_item()
				return
		
		remove_item(item_held_id, last_slot, get_slot_type(last_slot))
		insert_item(item_held_id, control, get_slot_type(control))
		# Move item TextureRects.
		item_held.rect_global_position = control.rect_global_position + control.rect_size / 2 - item_held.rect_size / 2
		slots[last_slot] = null
		slots[control] = item_held
		item_held = null
		
	# Swap items if the slot is not empty.
	elif slots.get(control) != null:
		var other_item_id = get_item_id_from_slot(control)
		# Check for valid equipment slot.
		if get_slot_type(last_slot) == "Equipment" or get_slot_type(control) == "Equipment":
			if !item_has_slot_type(item_held_id) and !item_has_slot_type(other_item_id):
				if get_item_slot_type(item_held_id) != get_item_slot_type(other_item_id):
					return_item()
					return
			
		swap_items(item_held_id, other_item_id, last_slot, control)
			
		# Swap items' TextureRects.
		var other_item = slots.get(control)
		other_item.rect_global_position = last_slot.rect_global_position + last_slot.rect_size / 2 - other_item.rect_size / 2
		item_held.rect_global_position = control.rect_global_position + control.rect_size / 2 - item_held.rect_size / 2
		slots[last_slot] = other_item
		slots[control] = item_held
		item_held = null
		
	else:
		return_item()


func swap_items(item1_id, item2_id, slot1, slot2):
	remove_item(item1_id, slot1, get_slot_type(slot1))
	remove_item(item2_id, slot2, get_slot_type(slot2))
	insert_item(item1_id, slot2, get_slot_type(slot2))
	insert_item(item2_id, slot1, get_slot_type(slot1))


func item_has_slot_type(item_id):
	var item_properties = Items.get_item(item_id)
	return item_properties.has("slot")


func get_item_slot_type(item_id):
	var item_properties = Items.get_item(item_id)
	return Items.ITEMS[item_properties.get("name")]["slot"]


func get_item_id_from_slot(slot):
	if get_slot_type(slot) == "Inventory":
		return player_inventory.get(slot)
	elif get_slot_type(slot) == "Equipment":
		return player_equipment.get(slot)
	elif get_slot_type(slot) == "Loot":
		return bag_slots.get(slot)


func remove_item(item_id, slot, slot_type):
	match slot_type:
		"Equipment":
			player_equipment[slot] = null
		"Inventory":
			player_inventory[slot] = null
		"Loot":
			if current_bag != null:
				bag_slots[slot] = null
				current_bag.remove_item_from_slot(slot)


func insert_item(item_id, slot, slot_type):
	match slot_type:
		"Equipment":
			player_equipment[slot] = item_id
		"Inventory":
			player_inventory[slot] = item_id
		"Loot":
			if current_bag != null:
				print(slot.name)
				print(slot_type)
				bag_slots[slot] = item_id
				current_bag.insert_item(item_id, slot)


func drop_item(item_id, slot_type):
	item_held.queue_free()
	match slot_type:
		"Equipment":
			player_equipment[last_slot] = null
		"Inventory":
			player_inventory[last_slot] = null
		"Loot":
			return_item()
			return
			
	slots[last_slot] = null
	
	if current_bag != null:
		current_bag.insert_item(item_id)
		return		
		
	var loot_bag = LootBag.instance()
	get_tree().root.get_node("World").add_child(loot_bag)
	loot_bag.insert_item(item_id)
	loot_bag.global_transform = player.global_transform
	loot_bag.translation -= Vector3(0, 0.25, 0)
	

func get_slot_type(slot):
	if slot.get_parent() == $Equipment:
		return "Equipment"
	elif slot.get_parent() == $Inventory:
		return "Inventory"
	elif slot.get_parent() == $LootBase/Loot:
		return "Loot"
	else:
		return null


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
