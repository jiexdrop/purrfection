extends RigidBody2D

var being_collected = false
var float_speed = 100
var fade_speed = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	Global.brushes += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if being_collected:
		# Move upward
		position.y -= float_speed * delta
		
		# Fade out
		modulate.a -= fade_speed * delta
		
		# Once fully transparent, remove the node
		if modulate.a <= 0:
			Global.brushes -= 1
			queue_free()

func _physics_process(delta: float) -> void:
	if not being_collected:  # Only check collisions if not already being collected
		for body in get_colliding_bodies():
			if body.is_in_group("Ball") or body.is_in_group("Character"):
				collect()

func collect() -> void:
	being_collected = true
	Global.collected_brushes += 1
	# Disable physics while animating
	freeze = true
	collision_layer = 0
	collision_mask = 0


func _on_timer_timeout() -> void:
	queue_free()
