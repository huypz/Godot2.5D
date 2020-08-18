extends Sprite3D

# Physics properties
var direction setget set_direction

# Projectile properties
var duration := 3
var speed := 10

func _ready():
	# Projectile disappears after duration
	var timer = Timer.new()
	timer.one_shot = true
	timer.set_wait_time(duration)
	timer.connect("timeout", self, "despawn")
	add_child(timer)
	timer.start()

	look_at(direction, Vector3(0, 1, 0))

func _physics_process(delta):
	pass


func set_direction(dir):
	direction = dir


func despawn():
	queue_free()
