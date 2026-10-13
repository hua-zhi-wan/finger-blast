extends Control


func _ready() -> void:
	Global.score = 0
	Global.need_submit = false
	$Control/ButtonPlay.grab_focus()


#func _input(event: InputEvent) -> void:
	#for event_name in ["move_left", "move_right", "move_up", "move_down", "fire"]:
		#if event.is_action(event_name):
			#if is_inside_tree():
				#get_tree().change_scene_to_file("res://scenes/game.tscn")
	#
	#if event.is_action_pressed("pause"):
		#get_tree().quit()


func _on_button_play_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_ranking_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/leaderboard_panel.tscn")


func _on_button_full_screen_pressed() -> void:
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_button_sound_pressed() -> void:
	AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))


func _on_button_language_pressed() -> void:
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	get_tree().quit()
