extends RigidBody2D

@export var explosion_radius: float = 150.0
@export var explosion_force: float = 500.0
@export var explosion_effect_scene: PackedScene  

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 2
	Global.bombs += 1

func _physics_process(_delta: float) -> void:
	var colliding_bodies = get_colliding_bodies()
	if colliding_bodies.size() > 0:
		for body in colliding_bodies:
			if body.is_in_group("Box"):
				explode()
				break

func explode() -> void:
	# Create explosion visual effect
	var explosion_effect = explosion_effect_scene.instantiate()
	if get_parent():
		get_parent().add_child(explosion_effect)
		explosion_effect.global_position = global_position
	
	# Create physics query
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = collision_mask  # Use the same collision mask as the bomb
	
	var space = get_world_2d().direct_space_state
	var results = space.intersect_shape(query)
	
	# Apply explosion forces
	for result in results:
		var body = result["collider"]
		if body != self and body.is_in_group("Box") and body is RigidBody2D:
			apply_explosion_force(body)
			# Optional: Add destruction animation for boxes
			body.kill(4)
	
	# Remove the bomb
	Global.bombs -= 1
	queue_free()


func apply_explosion_force(body: RigidBody2D) -> void:
	var direction = (body.global_position - global_position).normalized()
	var distance = global_position.distance_to(body.global_position)
	# Ensure we don't divide by zero if explosion_radius is 0
	var force_multiplier = (1.0 - clamp(distance / explosion_radius, 0.0, 1.0)) if explosion_radius > 0.0 else 1.0
	var force = direction * explosion_force * force_multiplier
	body.apply_central_impulse(force)
