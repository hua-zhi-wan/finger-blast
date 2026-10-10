extends Enemy
class_name Swinger


var move_horizontal_direction := 1
var move_vertical_diretion := 1


func _process(delta: float) -> void:
	$Sprite2D.flip_h = move_horizontal_direction < 0
	position.x += delta * move_horizontal_direction * move_speed
	position.y += delta * move_vertical_diretion * move_speed
	
	if global_position.x >= 16 * 19:
		move_horizontal_direction = -1
	elif global_position.x <= 0:
		move_horizontal_direction = 1

	if global_position.y >= 16 * 14:
		move_vertical_diretion = -1
	elif global_position.y <= 16 * 10:
		move_vertical_diretion = 1
