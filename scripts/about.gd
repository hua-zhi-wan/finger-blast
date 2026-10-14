extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().quit(0)


func _on_timer_timeout() -> void:
	get_tree().quit(0)
