extends Node

class_name Transitions

var queue : Array


func player_within(host, target_state, distance):
	var player = host.get_player()
	var actual_distance = player.global_transform.origin - host.global_transform.origin
	if (actual_distance.length() <= distance):
		host.set_state(target_state)


func next(host, target_state, duration = 0):
	if (self.queue.has(host)):
		return
		
	self.queue.append(host)

	if (duration > 0):
		var timer = Timer.new()
		timer.set_wait_time(duration)
		timer.set_one_shot(true)
		timer.set_autostart(true)
		host.add_child(timer)
		yield(timer, "timeout")
	
	self.queue.erase(host)
	if (host):
		host.set_state(target_state)
