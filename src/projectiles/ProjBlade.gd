extends Area

# Physics properties
var source setget set_source
var angle := 0 setget set_angle

# Projectile properties
var duration := 5 setget set_duration
var speed := 10 setget set_speed, get_speed

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


func set_source(node):
	source = node


func set_speed(value):
	speed = value
	
	
func set_duration(sec):
	duration = sec
	
	
func set_angle(rad):
	angle = rad


func get_speed():
	return speed


func despawn():
	queue_free()


func _on_ProjBlade_body_entered(body):
	if (body != source):
		queue_free()
