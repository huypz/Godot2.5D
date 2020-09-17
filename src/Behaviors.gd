extends Node

class_name Behaviors

var delta : float setget set_delta

var wander_direction : float
var wander_remaining_distance : float


func idle(host):
	var velocity = Vector3.ZERO
	host.set_velocity(velocity)


func follow(host, speed, acquire_radius = 14, radius = 7, duration = 0):
	var player = host.get_player()
	var player_dist = (player.global_transform.origin - host.global_transform.origin).length()
	acquire_radius *= 2
	radius *= 2
	# Only follow if player is in acquire_radius but outside radius
	if (player_dist <= acquire_radius and player_dist >= radius):
		var direction = host.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
		host.global_transform = direction
		host.set_velocity(Vector3(0, 0, -speed * delta))
		host.translate_object_local(Vector3(0, 0, -speed * delta))


# shoot_angle = 90, fixed_angle = 90
func shoot(host, projectile, radius = 0, count = 1, delay = 0, shoot_angle = null, 
  fixed_angle = null, angle_offset = 0, default_angle = null, predictive = 0):
	if delay > 0:
		delay /= 1000.0
		yield(host.get_tree().create_timer(delay), "timeout")
	var player = host.get_player()
	# Tile length conversion
	radius *= 2
	# Only shoot if radius is in range or 0 if auto
	if (radius == 0 or (player.global_transform.origin - host.global_transform.origin).length() <= radius):
		shoot_angle = shoot_angle if (shoot_angle != null) else (360.0 / count)
		shoot_angle = 0 if (count == 1) else (shoot_angle * PI / 180.0)
		fixed_angle =  fixed_angle * PI / 180.0 if fixed_angle else null
		angle_offset *= PI / 180.0
		default_angle = default_angle * PI / 180.0 if default_angle else null
	
		
		# Fixed angle or angled at target?
		var angle = host.global_transform.rotated(Vector3.UP, fixed_angle) if fixed_angle else host.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
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
			host.get_tree().root.get_node("World").add_child(proj)
			proj.global_transform = start_angle.rotated(Vector3.UP, shoot_angle * i)
			proj.global_transform.origin = host.global_transform.origin
		
		
func wander(host, speed, distance = 0.8):	
	var player = host.get_player()
	randomize()
	host.global_transform = host.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
	
	if wander_remaining_distance <= 0:
		wander_direction = randf() * 2 * PI
		wander_remaining_distance = distance

	var distance_traveled = speed * delta
	var velocity = Vector3.FORWARD.rotated(Vector3.UP, wander_direction) * distance_traveled
	host.set_velocity(velocity)
	host.translate_object_local(velocity)
	
	wander_remaining_distance -= distance_traveled
	
	
#	var direction = host.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
#	host.global_transform = direction
#	host.set_velocity(speed)
#	host.translate_object_local(Vector3(0, 0, -speed * delta))
	

func set_delta(sec):
	delta = sec
