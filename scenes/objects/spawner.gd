extends Area2D

@export var scenes: Array[PackedScene] # Array of scenes

func _on_timer_timeout() -> void:
	if scenes.is_empty():
		return
	
	var weights = [0.75, 0.25, 0.05]  # Adjust probabilities
	var index = weighted_random_index(weights)
	create(scenes[index])

func weighted_random_index(weights: Array) -> int:
	var r = randf()
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
	queue_free()
