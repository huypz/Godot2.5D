extends KinematicBody

# USAGE
# shoot(host, projectile, radius, count = 1, shoot_angle = null, 
#  fixed_angle = null, angle_offset = 0, default_angle = null, predictive = 0)

const Projectile = preload("res://src/projectiles/ProjBlade.tscn")

var Behavior
var Transition
var player setget , get_player

enum States {
	IDLE,
	WANDER,
	ATTACK
}
var state = States.IDLE setget set_state

var velocity : Vector3 setget set_velocity, get_velocity


func _ready():
	Behavior = Behaviors.new()
	Transition = Transitions.new()
	player = get_tree().root.get_node("World/Player")


func _physics_process(delta):
	Behavior.set_delta(delta)
	
	match state:
		States.IDLE:
			Behavior.idle(self)
			Transition.player_within(self, States.WANDER, 10)
		States.WANDER:
			Behavior.wander(self, 3)
			Transition.next(self, States.ATTACK, 1)
		States.ATTACK:
			Behavior.shoot(self, Projectile, 8, 5, 10, null, 0, null, 0.3)
			Transition.next(self, States.WANDER)
			
	update_animation()
			


func update_animation():
	if (velocity.length() > 0):
		$AnimatedSprite3D.play("walk")
	elif (velocity.length() == 0):
		$AnimatedSprite3D.play("idle")


func set_velocity(target_velocity):
	velocity = target_velocity
	
	
func set_state(target_state):
	state = target_state
	
	
func get_velocity():
	return velocity
	

func get_player():
	return player
