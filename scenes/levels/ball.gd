extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite

@export var bounce_factor: float = 1.2  # Increase bounce intensity
@export var min_velocity: float = 20.0  # Minimum velocity to prevent sticking
@export var max_velocity: float = 800.0  # Prevent excessive speed
@export var unstick_force: float = 100.0  # Force to apply when stuck

var original_texture = preload("res://images/knot.png")
var paint_texture = preload("res://images/knot_p.png")


func _ready():
	# Set up physics properties
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.8
	physics_material_override.friction = 0.2
	contact_monitor = true
	max_contacts_reported = 4
	SignalBus.brush.connect(_brush)
	
func _brush(val):
	if val:
		sprite.texture = paint_texture
	else:
		sprite.texture = original_texture

func _physics_process(delta):
	# Check if the ball is moving too slowly (potentially stuck)
	if linear_velocity.length() < min_velocity and linear_velocity.length() > 0:
		# Add a random impulse to unstick
		var random_angle = randf_range(0, 2 * PI)
		var unstick_impulse = Vector2(cos(random_angle), sin(random_angle)) * unstick_force
		apply_central_impulse(unstick_impulse)
	
	# Enforce maximum velocity
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	# Add some fun effects on collision
	for body in get_colliding_bodies():
		if body.is_in_group("Box"):
			SignalBus.brush.emit(false)
			Global.brush = false
		if body:
			# Increase velocity on bounce
			linear_velocity *= bounce_factor
			
			# Optional: Add rotation on collision
			angular_velocity = randf_range(-10, 10)
			
			# Optional: Add a random "kick" on collision
			var random_kick = Vector2(randf_range(-100, 100), randf_range(-100, 100))
			apply_central_impulse(random_kick)
