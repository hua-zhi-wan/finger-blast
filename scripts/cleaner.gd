extends Enemy
class_name Cleaner


var move_horizontal_direction := 1


func _process(delta: float) -> void:
	$Sprite2D.flip_h = move_horizontal_direction < 0
	position.x += delta * move_horizontal_direction * move_speed
