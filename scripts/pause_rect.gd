extends ColorRect


@export var button_resume: Button


func _ready() -> void:
	hide()
	for button in get_children():
		if button is Button:
			button.focus_entered.connect(SE.play_sound.bind("Click"))
			button.mouse_entered.connect(SE.play_sound.bind("Click"))
			button.pressed.connect(SE.play_sound.bind("Press"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		SE.play_sound("Pause")
		if get_tree().paused:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			button_resume.grab_focus()
			show()


func _on_button_resume_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_button_quit_pressed() -> void:
	if is_inside_tree():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/title.tscn")
