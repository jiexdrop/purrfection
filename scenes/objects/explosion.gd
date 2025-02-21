extends Node2D

@export var ring_texture: Texture2D 
@onready var sprite: Sprite2D = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = ring_texture

	# Start with zero scale and full opacity
	sprite.scale = Vector2.ZERO
	sprite.modulate.a = 1.0
	
	# Create and configure tween
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# Add the scale tween
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.3)
	# Add the fade tween
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	
	# Connect to the finished signal to clean up
	tween.finished.connect(func(): self.queue_free())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
