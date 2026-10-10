extends Control


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
