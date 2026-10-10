extends Enemy
class_name Soldier


var move_horizontal_direction: int = 1
var move_vertical_direction: int = 1
var is_vertical_walk: bool
var target_y = 0


func _process(delta: float) -> void:
	var move_direction = Vector2(0, 0)
	if not is_vertical_walk:
		move_direction.x = move_horizontal_direction
		$Sprite2D.flip_h = move_horizontal_direction < 0
		set_collision_mask_value(1, true)
	else:
		move_direction.y = move_vertical_direction
		set_collision_mask_value(1, false)
	if test_move(transform, move_speed * move_direction * delta):
		if not is_vertical_walk:
			move_horizontal_direction = -move_horizontal_direction
			is_vertical_walk = true
			target_y = roundi(global_position.y / 16 + move_vertical_direction) * 16
			if target_y >= 16 * 15 and move_vertical_direction > 0:
				target_y = roundi(global_position.y / 16 - 1) * 16
				move_vertical_direction = -1
			if target_y <= 16 * 10 and move_vertical_direction < 0:
				target_y = roundi(global_position.y / 16 + 1) * 16
				move_vertical_direction = 1
	
	if move_vertical_direction > 0:
		if global_position.y >= target_y:
			is_vertical_walk = false
			global_position.y = target_y
	elif move_vertical_direction < 0:
		if global_position.y <= target_y:
			is_vertical_walk = false
			global_position.y = target_y
	
	move_and_collide(move_speed * move_direction * delta)
