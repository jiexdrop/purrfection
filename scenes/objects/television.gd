extends RigidBody2D

@onready var break_stream_player: AudioStreamPlayer = $BreakStreamPlayer
var television_part_scene = load("res://scenes/objects/television_part.tscn") as PackedScene

var break_texture_left = preload("res://images/tv_break_left.png")
var break_texture_right = preload("res://images/tv_break_right.png")
var break_sound = preload("res://sounds/glass.mp3")

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Hammer"):
		break_tv()

func break_tv() -> void:
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = break_sound
	sound_player.autoplay = true
	get_tree().current_scene.add_child(sound_player)
	sound_player.finished.connect(sound_player.queue_free) 
	
	# Create left piece
	var left_piece = television_part_scene.instantiate()
	left_piece.texture = break_texture_left
	# Create right piece
	var right_piece = television_part_scene.instantiate()
	right_piece.texture = break_texture_right
	
	# Position pieces
	left_piece.global_position = global_position + Vector2(-30, 0)
	right_piece.global_position = global_position + Vector2(30, 0)
	
	# Add to scene
	get_tree().current_scene.add_child(left_piece)
	get_tree().current_scene.add_child(right_piece)
	
	# Apply impulses for animation
	left_piece.apply_central_impulse(Vector2(-100, -50))  # Push left and slightly up
	right_piece.apply_central_impulse(Vector2(100, -50))   # Push right and slightly up
	
	# Add rotation
	left_piece.apply_torque_impulse(-200)   # Rotate left piece
	right_piece.apply_torque_impulse(200)   # Rotate right piece
	
	# Remove original TV
	queue_free()
