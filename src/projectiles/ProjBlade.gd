extends Area

# Physics properties
var source setget set_source
var target_pos setget set_target_pos

# Projectile properties
var duration := 3
var speed := 15

func _ready():
	# Projectile disappears after duration
	var timer = Timer.new()
	timer.one_shot = true
	timer.set_wait_time(duration)
	timer.connect("timeout", self, "despawn")
	add_child(timer)
	timer.start()
	

func _physics_process(delta):
	translate_object_local(Vector3(0, 0, -speed * delta))


func set_target_pos(pos):
	global_transform = global_transform.looking_at(pos, Vector3.UP)
	set_rotation_degrees(Vector3(0, rotation_degrees.y, rotation_degrees.z))


func set_source(node):
	source = node


func despawn():
	queue_free()


func _on_ProjBlade_body_entered(body):
	if (body != source):
		queue_free()
