extends KinematicBody

const Projectile1 = preload("res://src/projectiles/WhiteBullet.tscn")
const Projectile2 = preload("res://src/projectiles/FireBolt.tscn")

var Behavior
var Transition
var player setget , get_player

enum States {
	SEARCH,
	WAIT,
	ATTACK,
}
var state = States.SEARCH setget set_state

var velocity : Vector3 setget set_velocity, get_velocity


func _ready():
	Behavior = Behaviors.new()
	Transition = Transitions.new()
	player = get_tree().root.get_node("World/Player")


func _physics_process(delta):
	Behavior.set_delta(delta)
	
	match state:
		States.SEARCH:
			Behavior.wander(self, 3)
			Behavior.follow(self, 5, 14, 1)
			Transition.player_within(self, States.ATTACK, 2)
		States.ATTACK:
			Transition.cooldown(self, States.ATTACK, 10000)
			Behavior.shoot(self, Projectile1, 0, 4, 0, 90, 90)
			Behavior.shoot(self, Projectile1, 0, 4, 200, 90, 100)
			Behavior.shoot(self, Projectile1, 0, 4, 400, 90, 110)
			Behavior.shoot(self, Projectile1, 0, 4, 600, 90, 120)
			Behavior.shoot(self, Projectile1, 0, 4, 800, 90, 130)
			Behavior.shoot(self, Projectile1, 0, 4, 1000, 90, 140)
			Behavior.shoot(self, Projectile1, 0, 4, 1200, 90, 150)
			Behavior.shoot(self, Projectile1, 0, 4, 1400, 90, 160)
			Behavior.shoot(self, Projectile1, 0, 4, 1600, 90, 170)
			Behavior.shoot(self, Projectile1, 0, 4, 1800, 90, 180)
			Behavior.shoot(self, Projectile1, 0, 12, 2000, null, 135)
			Behavior.shoot(self, Projectile1, 0, 4, 0, 90, 180)
			Behavior.shoot(self, Projectile1, 0, 4, 200, 90, 170)
			Behavior.shoot(self, Projectile1, 0, 4, 400, 90, 160)
			Behavior.shoot(self, Projectile1, 0, 4, 600, 90, 150)
			Behavior.shoot(self, Projectile1, 0, 4, 800, 90, 140)
			Behavior.shoot(self, Projectile1, 0, 4, 1000, 90, 130)
			Behavior.shoot(self, Projectile1, 0, 4, 1200, 90, 120)
			Behavior.shoot(self, Projectile1, 0, 4, 1400, 90, 110)
			Behavior.shoot(self, Projectile1, 0, 4, 1600, 90, 100)
			Behavior.shoot(self, Projectile1, 0, 4, 1800, 90, 90)
			Transition.next(self, States.WAIT)
		States.WAIT:
			Behavior.idle(self)
			Transition.next(self, States.SEARCH, 4000)
			
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
