extends Node



func play_sound(se_name: String, pitch: float = 1.0) -> void:
	var se = get_node(se_name) as AudioStreamPlayer
	if se:
		se.pitch_scale = pitch
		se.play()
