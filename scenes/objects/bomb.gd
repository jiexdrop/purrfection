extends RigidBody2D

@onready var explosion_stream_player: AudioStreamPlayer = $ExplosionStreamPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var explosion_radius: float = 150.0
@export var explosion_force: float = 500.0
@export var explosion_effect_scene: PackedScene
@export var bounce_force: float = 200.0  # Force applied when bouncing off walls

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 2
	Global.bombs += 1
	explosion_stream_player.finished.connect(_on_explosion_finished)
	
	# Set physics material for bouncing
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.8  # Bounciness factor (0.0 to 1.0)
	physics_material.friction = 0.1  # Lower friction for better sliding
	physics_material_override = physics_material

func _physics_process(_delta: float) -> void:
	var colliding_bodies = get_colliding_bodies()
	if colliding_bodies.size() > 0:
		for body in colliding_bodies:
			if body.is_in_group("Breakable"):
				explode()
				break
			elif body.is_in_group("Wall"):
				# Apply bounce effect when hitting walls
				handle_wall_bounce(body)

func handle_wall_bounce(wall_body) -> void:
	# Calculate reflection direction
	var collision_normal = (global_position - wall_body.global_position).normalized()
	var current_velocity = linear_velocity
	
	# Reflect velocity based on collision normal
	var reflected_velocity = current_velocity.reflect(collision_normal)
	
	# Apply the reflected velocity with additional bounce force
	linear_velocity = reflected_velocity * 1.1  # Slight speed boost
	apply_central_impulse(collision_normal * bounce_force)
	
	# Optional: Add a small spin for visual effect
	apply_torque_impulse(randf_range(-5000, 5000))

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
		if body != self and body.is_in_group("Breakable") and body is RigidBody2D:
			apply_explosion_force(body)
			# Optional: Add destruction animation for boxes
			body.kill(4)
	
	explosion_stream_player.play()
	sprite_2d.visible = false

func _on_explosion_finished():
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
