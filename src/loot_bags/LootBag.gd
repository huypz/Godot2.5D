extends Sprite3D

var duration := 180

# SLOT : ITEM_ID
var slots : Dictionary setget , get_slots


func _ready():
	# Set up slots
	for slot in get_tree().root.get_node("World/Player/HUD/LootBase/Loot").get_children():
		slots[slot] = null
	
	# Bag despawns after 'duration' seconds
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.connect("timeout", self, "despawn")
	add_child(timer)
	timer.start()


func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		print(slots)
	
	var item_found = false
	for item in slots.values():
		if item != null:
			item_found = true
			break
			
	if !item_found:
		despawn()


func insert_item(item_id, slot = get_available_slot()):
	slots[slot] = item_id
	
func remove_item(slot):
	slots[slot] = null
	

func get_available_slot():
	for slot in slots:
		if slots.get(slot) == null:
			return slot
	return null


func get_slots():
	return slots.duplicate()


func despawn():
	for slot in slots:
		if slots.get(slot) != null:
			Items.remove(slots.get(slot))
	queue_free()
