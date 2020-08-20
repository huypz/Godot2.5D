extends Node

class_name Behaviors

var delta : float setget set_delta

var wander_direction : Vector3
var wander_remaining_distance : float


func idle(host):
	var velocity = Vector3.ZERO
	host.set_velocity(velocity)


func wander(host, speed, distance = 0.5):
	randomize()
	
	if wander_remaining_distance <= 0:
		wander_direction = Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI)
		wander_direction = wander_direction.normalized()
		wander_remaining_distance = distance

	var distance_traveled = speed * delta
	var velocity = wander_direction * distance_traveled
	host.move_and_collide(velocity)
	host.set_velocity(velocity)
	
	wander_remaining_distance -= distance_traveled


func shoot(host, projectile, radius, count = 1, shoot_angle = null, 
  fixed_angle = null, angle_offset = 0, default_angle = null, predictive = 0):
	var player = host.get_player()
	
	shoot_angle = shoot_angle if (shoot_angle != null) else (360.0 / count)
	shoot_angle = 0 if (count == 1) else (shoot_angle * PI / 180.0)
	fixed_angle =  fixed_angle * PI / 180.0 if fixed_angle else null
	angle_offset *= PI / 180.0
	default_angle = default_angle * PI / 180.0 if default_angle else null

	
	# Fixed angle or angled at target?
	var angle = fixed_angle if fixed_angle else host.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
	angle = angle.rotated(Vector3.UP, angle_offset)
	
	# Predict player's movement and pos
	if (predictive != 0):
		var predicted_angle = host.global_transform.looking_at(player.global_transform.origin + player.global_direction * \
		  player.speed * predictive, Vector3.UP)
		angle = predicted_angle

	var start_angle = angle.rotated(Vector3.UP, -(shoot_angle * (count - 1) / 2))
	for i in range(0, count):
		var proj = projectile.instance()
		proj.set_source(host)
		proj.set_duration(5)
		proj.set_speed(10)
		host.get_tree().root.get_node("World").add_child(proj)
		proj.global_transform = start_angle.rotated(Vector3.UP, shoot_angle * i)
		proj.global_transform.origin = host.global_transform.origin
		
		
	

func set_delta(sec):
	delta = sec
