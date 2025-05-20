extends Area2D

@export var scenes: Array[PackedScene] # Array of scenes
@onready var sweep_stream_player: AudioStreamPlayer = $SweepStreamPlayer

var blink_timer: Timer
var is_visible_state: bool = true
var spawn: bool = true
@export var blink_speed: float = 0.5 # Time in seconds for each blink

func _ready() -> void:
	blink_timer = Timer.new()
	add_child(blink_timer)
	blink_timer.wait_time = blink_speed
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	blink_timer.start()
	sweep_stream_player.play()

func _on_blink_timer_timeout() -> void:
	is_visible_state = !is_visible_state
	var tween = create_tween()
	if is_visible_state:
		tween.tween_property(self, "modulate:a", 1.0, blink_speed/2)
	else:
		tween.tween_property(self, "modulate:a", 0.0, blink_speed/2)

func _on_timer_timeout() -> void:
	if scenes.is_empty():
		return
	
	var weights = [0.20, 0.20, 0.20, 0.20, 0.20]  # Adjust probabilities
	#var weights = [0.50, 0.0, 0.50] # Plop
	var index = weighted_random_index(weights)
	if Global.boxes >= 3:
		weights = [0.15, 0.25, 0.5, 0.15, 0.10]  # Adjust probabilities
	if Global.bombs >= 2:
		index = 0
	if spawn:
		create(scenes[index])
	queue_free()

func weighted_random_index(weights: Array) -> int:
	# Calculate sum of all weights
	var sum = 0.0
	for weight in weights:
		sum += weight
	
	# Generate random value between 0 and sum
	var r = randf() * sum
	var cumulative = 0.0
	
	for i in range(weights.size()):
		cumulative += weights[i]
		if r < cumulative:
			return i
	
	return weights.size() - 1  # Fallback

func create(scene: PackedScene):
	var instance = scene.instantiate()
	instance.position = global_position
	get_parent().add_child(instance)


func _on_body_entered(body: Node2D) -> void:
	spawn = false # do not spawn
