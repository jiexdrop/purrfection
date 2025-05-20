extends RigidBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var texture: Texture
@onready var break_stream_player: AudioStreamPlayer = $BreakStreamPlayer

var break_texture_left = preload("res://images/tv_break_left_top.png")
var break_texture_right = preload("res://images/tv_break_left_bottom.png")
var min_impact_velocity = 600.0  # Minimum velocity required to break

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	sprite_2d.texture = texture

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ball") or body.is_in_group("Hammer"):
		# Check if the impact velocity is high enough
		var relative_velocity = (body.linear_velocity - linear_velocity).length()
		if relative_velocity >= min_impact_velocity:
			spawn_break_pieces()

func spawn_break_pieces():
	SignalBus.score.emit(1000)
	# Create left piece
	var left_piece = RigidBody2D.new()
	var left_sprite = Sprite2D.new()
	left_sprite.texture = break_texture_left
	left_piece.add_child(left_sprite)
	left_piece.position = position
	left_piece.linear_velocity = Vector2(-100, -100)  # Adjust force as needed
	left_piece.angular_velocity = -2  # Add some rotation
	
	# Create right piece
	var right_piece = RigidBody2D.new()
	var right_sprite = Sprite2D.new()
	right_sprite.texture = break_texture_right
	right_piece.add_child(right_sprite)
	right_piece.position = position
	right_piece.linear_velocity = Vector2(100, -100)  # Adjust force as needed
	right_piece.angular_velocity = 2  # Add some rotation
	
	# Add both pieces to the scene
	get_parent().add_child(left_piece)
	get_parent().add_child(right_piece)
	
	# Set up auto-removal of pieces
	var timer = Timer.new()
	timer.wait_time = 1.0  # Adjust time as needed
	timer.one_shot = true
	timer.timeout.connect(func(): left_piece.queue_free(); right_piece.queue_free())
	get_parent().add_child(timer)
	timer.start()
	
	
	var sound_player = AudioStreamPlayer.new()
	sound_player.stream = break_stream_player.stream
	sound_player.autoplay = true
	get_tree().current_scene.add_child(sound_player)
	sound_player.finished.connect(sound_player.queue_free) 
	queue_free()

func kill(hits):
	spawn_break_pieces()
