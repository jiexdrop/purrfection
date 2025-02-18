extends Area2D

@export var scenes: Array[PackedScene] # Array of scenes

func _on_timer_timeout() -> void:
	if scenes.is_empty():
		return
	create(scenes[randi() % scenes.size()])

func create(scene: PackedScene):
	var instance = scene.instantiate()
	instance.position = global_position
	get_parent().add_child(instance)
	queue_free()
