extends Area

# Physics properties
var source setget set_source
var angle setget set_angle

# Projectile properties
var duration := 3
var speed := 25

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


func set_angle(pos):
	global_transform = global_transform.looking_at(pos, Vector3.UP)
	#print(rotation_degrees)


func set_source(node):
	source = node


func despawn():
	queue_free()


func _on_ProjBlade_body_entered(body):
	print(body)
	if (body != source):
		queue_free()
