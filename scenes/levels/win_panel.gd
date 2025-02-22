extends Panel

var progress_right = 0
var progress_wrong = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	SignalBus.update_right.connect(update_progress_right)
	SignalBus.update_wrong.connect(update_progress_wrong)

func update_progress_right(progress_value):
	progress_right += progress_value
	if(progress_right >= 100):
		visible = true

func update_progress_wrong(progress_value):
	progress_wrong += progress_value


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/init.tscn") 
