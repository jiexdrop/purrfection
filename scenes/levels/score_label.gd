extends Label

func _ready() -> void:
	SignalBus.score.connect(update_score)

func update_score(value):
	Global.score += value
	text = str(Global.score)
