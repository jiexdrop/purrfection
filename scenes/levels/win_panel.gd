extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/init.tscn") 
