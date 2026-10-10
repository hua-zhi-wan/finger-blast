extends Control


func _input(event: InputEvent) -> void:
	for event_name in ["move_left", "move_right", "move_up", "move_down", "fire"]:
		if event.is_action(event_name):
			if is_inside_tree():
				get_tree().change_scene_to_file("res://scenes/game.tscn")
