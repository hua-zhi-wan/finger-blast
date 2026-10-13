extends Enemy
class_name Rusher


var target_y := 16


func _ready() -> void:
	$Sprite2D.flip_h = randf() < 0.5


func _process(delta: float) -> void:
	position.y += delta * move_speed
	if global_position.y > target_y and target_y < 12 * 16:
		if randf() < 0.5:
			game.tomb_queue.push_back(Vector2(global_position.x, target_y - 16))
		target_y += 16


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	game.rusher_queue += 1
	super._on_visible_on_screen_notifier_2d_screen_exited()
