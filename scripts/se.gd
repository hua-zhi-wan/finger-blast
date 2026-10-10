extends Node



func play_sound(se_name: String) -> void:
	var se = get_node(se_name) as AudioStreamPlayer
	if se:
		se.play()
