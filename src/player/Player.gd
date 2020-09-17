extends KinematicBody

const Projectile = preload("res://src/projectiles/WhiteBullet.tscn")

onready var camera = get_node("Camera")
#onready var cursor = get_node("Cursor")
onready var attack_ray = get_node("AttackRayCast")
onready var attack_timer = get_node("AttackTimer")
onready var hud = get_node("CanvasLayer/HUD")

# Player properties
var attack_cooldown : float = 0.25
var attacking : bool = false

# Physics
var cursor_pos : Vector3
var speed := 10
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
		inventory[get_node("CanvasLayer/HUD/Inventory/Slot" + str(i))] = null
		
	# Set up inventory slots.
	for slot in get_node("CanvasLayer/HUD/Equipment").get_children():
		equipment[slot] = null
		
	give_item("Steel Dagger")
	give_item("Dirk")
	give_item("Wolfskin Armor")


func _physics_process(delta):	
	global_direction = Vector3.ZERO
	
	process_cursor()
	process_input()
	if (!attacking):
		update_movement_animation()
	process_camera()
	
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
		
	global_direction = global_direction.normalized()
	local_direction = global_direction.normalized().rotated(Vector3(0, 1, 0), rotation.y)
		
	# Attack
	if Input.is_action_pressed("left_click"):
		attacking = true
		anim_player.stop()
		if (attack_timer.is_stopped()):
			attack();
	elif Input.is_action_just_released("left_click"):
		attacking = false
		
	if Input.is_action_just_pressed("debug"):
		print(global_transform.origin)
		print(global_direction.normalized() * speed)
		#print(global_direction.normalized())
		
		
func process_cursor():
	var ray_length = 100
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, false, true)
	if result:
		cursor_pos = result.get("position")
		#cursor.global_transform.origin = cursor_pos
		#cursor_pos.y = transform.origin.y
		
	
func process_camera():
	# Camera controls.
	if Input.is_action_pressed("rotate_right"):
		rotate_y(-PI * 0.01)
	elif Input.is_action_pressed("rotate_left"):
		rotate_y(PI * 0.01)	
		
		
func attack():
	attacking = true
	attack_timer.set_wait_time(attack_cooldown)
	attack_timer.start()
	
	var angle = global_transform.looking_at(cursor_pos, Vector3.UP)
	attack_ray.global_transform = angle
	
	var proj = Projectile.instance()
	proj.set_source(self)
	proj.set_speed(15)
	get_tree().root.get_node("World").add_child(proj)
	proj.global_transform = angle
	
	update_attack_animation()
	

func update_movement_animation():
	# Right
	if local_direction == Vector3(1, 0, 0).rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_right")
		facing = "right"
	# Left
	if local_direction == Vector3(-1, 0, 0).rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_left")
		facing = "left"
	# Up
	if local_direction == Vector3(0, 0, -1).rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_up")
		facing = "up"
	# Down
	if local_direction == Vector3(0, 0, 1).rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_down")
		facing = "down"
	# Top-right
	if local_direction == Vector3(1, 0, -1).normalized().rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_up")
		facing = "up"
	# Top-left
	if local_direction == Vector3(-1, 0, -1).normalized().rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_left")
		facing = "left"
	# Bottom-right
	if local_direction == Vector3(1, 0, 1).normalized().rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_right")
		facing = "right"
	# Bottom-left
	if local_direction == Vector3(-1, 0, 1).normalized().rotated(Vector3.UP, rotation.y):
		anim_player.play("walk_down")
		facing = "down"
	
	# Idle
	if local_direction == Vector3.ZERO:
		anim_player.play("idle_" + facing)


func update_attack_animation():
	var player_rotation = attack_ray.get_rotation_degrees().y
	
	if (player_rotation <= 45 and player_rotation >= -45):
		facing = "up"
		sprite.set_frame(14)
		yield(get_tree().create_timer(attack_cooldown / 2.0), "timeout")
		if (attacking):
			sprite.set_frame(13)
	elif (player_rotation <= -45 and player_rotation >= -135):
		facing = "right"
		sprite.set_frame(3)
		yield(get_tree().create_timer(attack_cooldown / 2.0), "timeout")
		if (attacking):
			sprite.set_frame(2)
	elif (player_rotation <= -135 or player_rotation >= 135):
		facing = "down"
		sprite.set_frame(19)
		yield(get_tree().create_timer(attack_cooldown / 2.0), "timeout")
		if (attacking):
			sprite.set_frame(18)
	elif (player_rotation <= 135 and player_rotation >= 45):
		facing = "left"
		sprite.set_frame(4)
		yield(get_tree().create_timer(attack_cooldown / 2.0), "timeout")
		if (attacking):
			sprite.set_frame(5)
	
		
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
		hud.show_loot_bag(area.get_parent())


func _on_Area_area_exited(area):
	if area.get_parent().is_in_group("loot_bag"):
		hud.hide_loot_bag(area.get_parent())
