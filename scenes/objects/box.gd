extends RigidBody2D

@onready var removal_timer: Timer = $RemovalTimer
@onready var hit_timer: Timer = $HitTimer

var hits := 0

var right = false
var can_hit = true

func _ready() -> void:
	randomize()
	right = randi() % 2 == 0 
	contact_monitor = true
	max_contacts_reported = 4

func _on_body_entered(body: Node) -> void:
	#print("Collision detected with: ", body.name)  # Debug print
	if body.is_in_group("Ball") and can_hit:
		if SignalBus.brush:
			right = true
			SignalBus.brush = false
		can_hit = false
		hits += 1
		hit_timer.start()
		if right:
			modulate = Color(1 - hits * 0.3, 1, 1 - hits * 0.3)
		else:
			removal_timer.start()
			modulate = Color(1, 1 - hits * 0.3, 1 - hits * 0.3)
		if hits >= 4:
			if right:
				SignalBus.update_right.emit(5)
				SignalBus.update_wrong.emit(-5)
			else:
				SignalBus.update_wrong.emit(5)
				SignalBus.update_right.emit(-5)
			queue_free()


func _on_removal_timer_timeout() -> void:
	queue_free()


func _on_hit_timer_timeout() -> void:
	can_hit = true
