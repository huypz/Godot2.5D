extends KinematicBody

const Projectile = preload("res://src/projectiles/ProjBlade.tscn")

onready var camera = get_node("Camera")
onready var cursor = get_node("Cursor")

# Physics
var cursor_pos : Vector3
var speed := 15
var global_direction : Vector3
var local_direction : Vector3

# Animations
var sprite
var anim_player
var facing = "right"

# Equipment  SLOT : ITEM
var equipment : Dictionary

# Inventory  SLOT : ITEM
var inventory : Dictionary
var inventory_size = 8

func _ready():
	sprite = get_node("Sprite3D")
	anim_player = get_node("AnimationPlayer")
	
	# Set up inventory slots.
	for i in range(1, inventory_size + 1):
		inventory[get_node("HUD/Inventory/Slot" + str(i))] = null
		
	# Set up inventory slots.
	for slot in get_node("HUD/Equipment").get_children():
		equipment[slot] = null
		
	give_item("Steel Dagger")
	give_item("Dirk")
	give_item("Wolfskin Armor")


func _physics_process(delta):	
	global_direction = Vector3.ZERO
	
	process_input()
	look_at_cursor()
	
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
		
	local_direction = global_direction.normalized().rotated(Vector3(0, 1, 0), rotation.y)
	
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
		
	# Attack
	if Input.is_action_just_pressed("left_click"):
		attack();
	elif Input.is_action_just_released("left_click"):
		pass
		
		
func attack():
	var proj = Projectile.instance()
	proj.set_source(self)
	get_tree().root.get_node("World").add_child(proj)
	proj.global_transform.origin = global_transform.origin
	proj.set_angle(cursor_pos)

		
func look_at_cursor():
	var ray_length = 100
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if result:
		cursor_pos = result.get("position")
		cursor.global_transform.origin = cursor_pos
		cursor_pos.y = transform.origin.y
	
		
func give_item(item_name):
	var available_slot = get_available_inventory_slot()
	if available_slot != null:
		# Generate a random id for the item
		randomize()
		var item_id = randi() % 1000
		while (Items.database.keys().has(item_id)):
			item_id = randi() % 1000
		Items.add_item(item_id, item_name)
		inventory[available_slot] = item_id
	else:
		return false
	
	
func get_available_inventory_slot():
	for slot in inventory:
		if inventory.get(slot) == null:
			return slot
	return null
	
	
func get_equipment():
	return equipment
	

func get_inventory():
	return inventory


func _on_Area_area_entered(area):
	if area.get_parent().is_in_group("loot_bag"):
		$HUD.show_loot_bag(area.get_parent())


func _on_Area_area_exited(area):
	if area.get_parent().is_in_group("loot_bag"):
		$HUD.hide_loot_bag(area.get_parent())
