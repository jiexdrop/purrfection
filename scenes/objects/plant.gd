extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var break_stream_player: AudioStreamPlayer = $BreakStreamPlayer
@onready var leaves_stream_player: AudioStreamPlayer = $LeavesStreamPlayer

var vase_texture = preload("res://images/vase.png")
var plant_texture = preload("res://images/plant.png")
var plant_smashed_texture = preload("res://images/plant_smashed.png")
var plant_smashed_no_vase_texture = preload("res://images/plant_smashed_no_vase.png")

var is_plant_smashed = false
var is_vase_separated = false
var vase_node: RigidBody2D = null

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ball") and not is_plant_smashed:
		leaves_stream_player.play()
		# Smash the plant first
		is_plant_smashed = true
		sprite_2d.texture = plant_smashed_texture
	elif body.is_in_group("Hammer") and is_plant_smashed and not is_vase_separated:
		break_stream_player.play()
		# Separate the vase from the plant when hit with hammer
		is_vase_separated = true
		
		# Change the main object to be just the smashed plant
		sprite_2d.texture = plant_smashed_no_vase_texture
		
		# Create the separated vase
		vase_node = RigidBody2D.new()
		var vase_sprite = Sprite2D.new()
		vase_sprite.texture = vase_texture
		vase_node.add_child(vase_sprite)
		
		# Set the vase position (adjust as needed based on your scene)
		vase_node.global_position = global_position + Vector2(0, -10)
		
		# Add collision shape for the vase
		var vase_collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 10  # Adjust based on your vase size
		vase_collision.shape = shape
		vase_node.add_child(vase_collision)
		
		# Apply a small force to make the vase move a bit
		vase_node.apply_impulse(Vector2(randf_range(-50, 50), -50))
		
		# Add the vase to the scene
		get_parent().add_child(vase_node)
		
		# Start the timer to remove both objects
		var timer = get_tree().create_timer(1.5)  # 1.5 seconds
		timer.timeout.connect(_on_removal_timer_timeout)

func _on_removal_timer_timeout() -> void:
	# Remove both the plant and the vase
	if vase_node != null and is_instance_valid(vase_node):
		vase_node.queue_free()
	SignalBus.score.emit(750)
	queue_free()
