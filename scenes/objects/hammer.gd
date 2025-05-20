extends RigidBody2D

@onready var hammer_stream_player: AudioStreamPlayer = $HammerStreamPlayer

# Bounce properties
@export var wall_bounce = 0.3  # How much bounce against walls (0-1)
@export var floor_bounce = 0.0  # No bounce against floors
@export var wall_repulsion_force = 120.0  # Lower force for more stable physics
@export var angular_dampening = 0.8  # Reduces spinning when hitting walls
@export var repulsion_cooldown = 0.12  # Time between repulsions

var can_repulse = true
var current_cooldown = 0.0
var wall_contact_points = []

func _ready():
	# Set the initial physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = wall_bounce
	physics_material.friction = 0.8
	physics_material_override = physics_material
	contact_monitor = true
	max_contacts_reported = 8  # Increased because of multiple collision shapes
	body_shape_entered.connect(_on_body_shape_entered)

func _physics_process(delta):
	# Handle cooldown timer
	if !can_repulse:
		current_cooldown -= delta
		if current_cooldown <= 0:
			can_repulse = true
	
	# Clear contact points each frame
	wall_contact_points.clear()

func _integrate_forces(state):
	# This gives us more control over physics
	if wall_contact_points.size() > 0 and can_repulse:
		# Calculate average wall normal
		var avg_normal = Vector2.ZERO
		for point in wall_contact_points:
			avg_normal += point
		avg_normal = avg_normal.normalized()
		
		# Get velocity component along the wall normal
		var normal_velocity = linear_velocity.project(avg_normal)
		
		# Calculate repulsion force - cancel normal velocity + add repulsion
		var repulsion = -normal_velocity * 1.2
		repulsion += avg_normal * wall_repulsion_force
		
		# Apply central impulse
		state.apply_central_impulse(repulsion)
		
		# Dampen angular velocity to prevent excessive spinning
		state.angular_velocity *= angular_dampening
		
		# Set cooldown
		can_repulse = false
		current_cooldown = repulsion_cooldown

func _on_body_entered(body):
	if body.is_in_group("Walls"):
		hammer_stream_player.play()
		
		# Set physics material for wall collisions
		physics_material_override.bounce = wall_bounce
		
		# Calculate direction from wall to hammer
		var normal = (global_position - body.global_position).normalized()
		
		# Add to contact points
		wall_contact_points.append(normal)
	else:
		# Reset bounce for other surfaces
		physics_material_override.bounce = floor_bounce

# Additional helper to handle ongoing collisions
func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.is_in_group("Walls"):
		# Get the collision normal based on the specific shapes that collided
		var normal = (global_position - body.global_position).normalized()
		wall_contact_points.append(normal)
