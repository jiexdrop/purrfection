extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var removal_timer: Timer = $RemovalTimer
@onready var hit_timer: Timer = $HitTimer

var box_textures = [
	preload("res://images/box2.png"),
	preload("res://images/box3.png"),
	preload("res://images/box4.png")
]

var break_texture_left = preload("res://images/box_break_left.png")
var break_texture_right = preload("res://images/box_break_right.png")

var hits := 0
var right = false
var can_hit = true
var is_destroyed := false

func _ready() -> void:
	randomize()
	right = randi() % 2 == 0
	right = false 
	contact_monitor = true
	max_contacts_reported = 4
	sprite.texture = box_textures[0]
	Global.boxes += 1 

func spawn_break_pieces():
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
	
	if right:
		left_piece.modulate = Color(1 - hits * 0.3, 1, 1 - hits * 0.3)
		right_piece.modulate = Color(1 - hits * 0.3, 1, 1 - hits * 0.3)
	else:
		left_piece.modulate = Color(1, 1 - hits * 0.3, 1 - hits * 0.3)
		right_piece.modulate = Color(1, 1 - hits * 0.3, 1 - hits * 0.3)
	
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

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Ball") and can_hit:
		can_hit = false
		hits += 1
		hit_timer.start()
		
		if Global.collected_brushes > 0 and right == false:
			right = true
			Global.collected_brushes -= 1
			
		if hits >= 3:
			kill(0)
		else:
			# Update sprite texture based on hits
			var texture_index = min(hits, box_textures.size() - 1)
			sprite.texture = box_textures[texture_index]
			
			# Keep the original color modulation
			if right:
				modulate = Color(1 - hits * 0.3, 1, 1 - hits * 0.3)
			else:
				modulate = Color(1, 1 - hits * 0.3, 1 - hits * 0.3)

func kill(hits):
	# Prevent multiple destructions
	if is_destroyed:
		return
	is_destroyed = true
	
	self.hits += hits
	if right:
		SignalBus.score.emit(5, -5)
	else:
		SignalBus.score.emit(-5, 5)
	
	# Spawn break pieces and hide original sprite
	spawn_break_pieces()
	sprite.visible = false
	removal_timer.start()

func _on_removal_timer_timeout() -> void:
	Global.boxes -= 1
	queue_free()

func _on_hit_timer_timeout() -> void:
	can_hit = true
