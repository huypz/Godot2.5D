extends Node

class_name Transitions

var cooldown : Array
var queue : Array


func cooldown(host, target_state, duration):
	if (self.cooldown.has(target_state)):
		return
		
	self.cooldown.append(target_state)
	var timer = Timer.new()
	timer.set_wait_time(duration / 1000.0)
	timer.set_one_shot(true)
	timer.set_autostart(true)
	host.add_child(timer)
	yield(timer, "timeout")
	
	self.cooldown.erase(target_state)
	


func player_within(host, target_state, distance):
	if (self.cooldown.has(target_state)):
		return
		
	var player = host.get_player()
	var actual_distance = player.global_transform.origin - host.global_transform.origin
	if (actual_distance.length() <= distance * 2):
		host.set_state(target_state)


func next(host, target_state, duration = 0):
	if (self.cooldown.has(target_state) or self.queue.has(host)):
		return
		
	self.queue.append(host)

	if (duration > 0):
		var timer = Timer.new()
		timer.set_wait_time(duration / 1000.0)
		timer.set_one_shot(true)
		timer.set_autostart(true)
		host.add_child(timer)
		yield(timer, "timeout")
	
	self.queue.erase(host)
	if (host):
		host.set_state(target_state)
