extends RigidBody2D

@onready var cat: Sprite2D = $Cat

var push_force: float = 100.0
var original_texture = preload("res://images/cat.png")
var cat_paw = preload("res://images/cat_paw.png")

@onready var paw_timer: Timer = $PawTimer

func _ready():
	# Configure RigidBody2D properties
	gravity_scale = 0  # Disable gravity
	lock_rotation = true  # Prevent rotation
	contact_monitor = true  # Enable collision monitoring
	max_contacts_reported = 4  # Number of simultaneous contacts to report
	
	# Set up collision layers
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
	# Timer setup
	paw_timer.wait_time = 0.125
	paw_timer.one_shot = true

func _physics_process(delta):
	var target_position = get_global_mouse_position()
	var movement_vector = target_position - global_position
	
	# Handle sprite flipping
	if cat.texture == original_texture:
		if movement_vector.x < 0:
			cat.scale.x = -1
		elif movement_vector.x > 0:
			cat.scale.x = 1
	
	# Move towards mouse position
	linear_velocity = movement_vector * 10  # Adjust this multiplier to control movement speed

func _integrate_forces(state):
	# Handle collisions
	if state.get_contact_count() > 0:
		for i in state.get_contact_count():
			var collider = state.get_contact_collider_object(i)
			if collider is RigidBody2D:
				cat.texture = cat_paw
				paw_timer.start()
				var collision_normal = state.get_contact_local_normal(i)
				collider.apply_central_impulse(-collision_normal * push_force)

func _on_paw_timer_timeout() -> void:
	cat.texture = original_texture
