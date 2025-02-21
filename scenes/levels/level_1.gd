extends Node2D

@export var spawner_scene: PackedScene  # Add this to reference your spawner scene

@export var spawn_width: float = 1152.0
@export var spawn_height: float = 648.0
@export var spawn_interval: float = 2
var spawn_timer: float = 0.0

# Add these variables for collision checking
@export var check_radius: float = 80.0  # Adjust based on your needs
var collision_shape: CollisionShape2D

func _ready():
	if not spawner_scene:
		print("Please assign a box scene in the inspector!")
	
	# Create a temporary collision shape for checking
	collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = check_radius
	collision_shape.shape = shape

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_random_box()
		spawn_timer = 0.0

func is_position_clear(pos: Vector2) -> bool:
	# Create a temporary physics check
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(0, pos)
	
	var results = space_state.intersect_shape(query)
	return results.is_empty()

func get_valid_spawn_position() -> Vector2:
	var max_attempts = 10  # Prevent infinite loops
	var attempts = 0
	
	while attempts < max_attempts:
		var random_x = randf_range(0, spawn_width)
		var random_y = randf_range(0, spawn_height)
		var test_pos = Vector2(random_x, random_y)
		
		if is_position_clear(test_pos):
			return test_pos
			
		attempts += 1
	
	return Vector2.ZERO  # Return default position if no valid position found

func spawn_random_box():
	if not spawner_scene:
		return
	
	var spawn_pos = get_valid_spawn_position()
	if spawn_pos != Vector2.ZERO:
		var spawner = spawner_scene.instantiate()
		spawner.position = spawn_pos
		add_child(spawner)
		
func _draw():
	#draw_rect(Rect2(Vector2.ZERO, Vector2(spawn_width, spawn_height)), Color.WHITE, false)
	pass
