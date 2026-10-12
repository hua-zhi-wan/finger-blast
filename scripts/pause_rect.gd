extends ColorRect


func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		SE.play_sound("Pause")
		if get_tree().paused:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()
