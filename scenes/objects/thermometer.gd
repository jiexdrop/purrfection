extends TextureProgressBar

@export var right = false
var tween: Tween

func _ready():
	tween = create_tween()

	SignalBus.score.connect(update_progress)

func update_progress(right, wrong):
	tween.stop()  # Stop any previous tween
	tween = create_tween()
	tween.tween_property(self, "value", value + (right if self.right else wrong), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)		
