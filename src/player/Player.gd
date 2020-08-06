extends KinematicBody

# Physics
var speed := 8
var global_direction : Vector3
var local_direction : Vector3

# Animations
var sprite
var anim_player
var facing = "right"

# Inventory  SLOT : ITEM
var inventory : Dictionary
var inventory_size = 8

func _ready():
	sprite = get_node("Sprite3D")
	anim_player = get_node("AnimationPlayer")
	
	# Set up inventory slots.
	for i in range(1, inventory_size + 1):
		inventory[get_node("HUD/Inventory/Slot" + str(i))] = null


func _physics_process(delta):
	if Input.is_action_just_pressed("debug"):
		print(inventory)
		
	global_direction = Vector3.ZERO
	
	process_input()
	
	local_direction = move_and_slide(local_direction * speed, Vector3(0, 1, 0))


func process_input():
	if Input.is_action_pressed("ui_right"):
		global_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		global_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		global_direction.z += 1
	if Input.is_action_pressed("ui_up"):
		global_direction.z -= 1
		
	local_direction = global_direction.rotated(Vector3(0, 1, 0), rotation.y)
	
	# Right
	if local_direction == Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_right")
		facing = "right"
	# Left
	if local_direction == Vector3(-1, 0, 0).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_left")
		facing = "left"
	# Up
	if local_direction == Vector3(0, 0, -1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_up")
		facing = "up"
	# Down
	if local_direction == Vector3(0, 0, 1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_down")
		facing = "down"
	# Top-right
	if local_direction == Vector3(1, 0, -1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_up")
		facing = "up"
	# Top-left
	if local_direction == Vector3(-1, 0, -1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_left")
		facing = "left"
	# Bottom-right
	if local_direction == Vector3(1, 0, 1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_right")
		facing = "right"
	# Bottom-left
	if local_direction == Vector3(-1, 0, 1).rotated(Vector3(0, 1, 0), rotation.y):
		anim_player.play("walk_down")
		facing = "down"
	
	
	if local_direction == Vector3.ZERO:
		anim_player.play("idle_" + facing)
	
	# Camera controls.
	if Input.is_action_pressed("rotate_right"):
		rotate_y(-PI * 0.01)
	elif Input.is_action_pressed("rotate_left"):
		rotate_y(PI * 0.01)	
		
		
func give_item(item):
	var available_slot = get_available_inventory_slot()
	if available_slot != null:
		inventory[available_slot] = item
	else:
		return false
	
	
func get_available_inventory_slot():
	for slot in inventory:
		if inventory.get(slot) == null:
			return slot
	return null
	

func get_inventory():
	return inventory
