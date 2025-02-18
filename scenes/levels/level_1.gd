extends Node2D

# Preload the box scene
@export var box_scene: PackedScene

# Define spawn area parameters
@export var spawn_width: float = 1152.0
@export var spawn_height: float = 648.0
@export var spawn_interval: float = 2  # Seconds between spawns
var spawn_timer: float = 0.0

func _ready():
	# Verify the box scene is assigned
	if not box_scene:
		print("Please assign a box scene in the inspector!")

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_random_box()
		spawn_timer = 0.0

func spawn_random_box():
	if not box_scene:
		return
		
	# Instance the box scene
	var box = box_scene.instantiate()
	
	# Calculate random position within spawn area
	var random_x = randf_range(0, spawn_width)
	var random_y = randf_range(0, spawn_height)
	
	# Set the position
	box.position = Vector2(random_x, random_y)
	
	# Add the box to the scene tree
	add_child(box)
