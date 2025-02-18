extends TextureProgressBar


@export var right = false

func _ready():
	if right:
		SignalBus.update_right.connect(update_progress)
	else:
		SignalBus.update_wrong.connect(update_progress)

func update_progress(progress_value):
	# Update the value and fill mode based on the new progress
	value = value + progress_value 
