extends Enemy
class_name Soldier


#@export var move_speed: float
#@export var max_life: int
#@export var price: int


var move_horizontal_direction: int = 1
var move_vertical_direction: int = 1
var is_vertical_walk: bool
var target_y = 0
#@onready var game := get_tree().get_first_node_in_group("game") as Game
#@onready var life := max_life
#@onready var original_color := modulate


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


#func _on_kill_all_tomb_body_entered(body: Node2D) -> void:
	#if body.has_method("hurt"):
		#body.queue_free()
#
#
#func hurt():
	#life -= 1
	#modulate.v = original_color.v * life / max_life
	#$Sprite2D.material.set_shader_parameter('enabled', true)
	#SE.play_sound("HitEnemy")
	#if life <= 0:
		#game.tomb_queue.append((global_position / 16).round() * 16)
		#queue_free()
		#SE.play_sound("KillEnemy")
		#var scoreup = ScoreUp.create()
		#game.add_child(scoreup)
		#scoreup.global_position = global_position
		#scoreup.score = price
	#await get_tree().create_timer(0.1).timeout
	#$Sprite2D.material.set_shader_parameter('enabled', false)
#
#
#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()
