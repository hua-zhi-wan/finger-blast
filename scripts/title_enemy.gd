extends Node2D


func _ready() -> void:
	$Sprite2D.hide()
	$Sprite2D2.hide()
	var sprite
	if randf() > 0.7:
		sprite = $Sprite2D2
	else:
		sprite = $Sprite2D
	sprite.show()
	sprite.flip_h = randf() < 0.5
	$AnimationPlayer.play(["jump", "walk"].pick_random())
	$AnimationPlayer.seek(randf_range(0, 0.4), true)
	$AnimationPlayer.speed_scale = randf_range(0.8, 1.2)
