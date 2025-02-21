extends TextureProgressBar

@export var right = false
var tween: Tween

func _ready():
	tween = create_tween()
	if right:
		SignalBus.update_right.connect(update_progress)
	else:
		SignalBus.update_wrong.connect(update_progress)

func update_progress(progress_value):
	tween.stop()  # Stop any previous tween
	tween = create_tween()
	tween.tween_property(self, "value", value + progress_value, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
