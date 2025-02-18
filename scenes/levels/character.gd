extends CharacterBody2D

@onready var cat: Sprite2D = $Cat

var dragging: bool = false
var offset: Vector2 = Vector2.ZERO
var push_force: float = 100.0
var original_texture = preload("res://images/cat.png")
var cat_paw = preload("res://images/cat_paw.png")

@onready var paw_timer: Timer = $PawTimer

func _ready():
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	paw_timer.wait_time = 0.125
	paw_timer.one_shot = true

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if cat.get_rect().has_point(cat.to_local(event.position)):
				dragging = !dragging
				offset = cat.global_position - event.global_position

func _physics_process(delta):
	if dragging:
		var target_position = get_global_mouse_position() + offset
		var movement_vector = target_position - global_position
		
		# Only flip the sprite if we're not showing the paw texture
		if cat.texture == original_texture:
			if movement_vector.x < 0:
				cat.scale.x = -1
			elif movement_vector.x > 0:
				cat.scale.x = 1
		
		velocity = movement_vector * 1000 * delta
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is RigidBody2D:
				cat.texture = cat_paw
				paw_timer.start()
				collider.apply_central_impulse(-collision.get_normal() * push_force)

func _on_paw_timer_timeout() -> void:
	cat.texture = original_texture
