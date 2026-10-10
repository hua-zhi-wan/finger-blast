extends CharacterBody2D
class_name Rusher


@export var move_speed: float
@export var max_life: int
@export var price: int


@onready var game := get_tree().get_first_node_in_group("game") as Game
@onready var life := max_life

var target_y := 16


func _ready() -> void:
	$Sprite2D.flip_h = randf() < 0.5


func _process(delta: float) -> void:
	position.y += delta * move_speed
	if position.y > target_y and target_y < 12 * 16:
		if randf() < 0.5:
			game.tomb_queue.push_back(Vector2(global_position.x, target_y - 16))
		target_y += 16


func _on_kill_all_tomb_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.queue_free()


func hurt():
	life -= 1
	$Sprite2D.material.set_shader_parameter('enabled', true)
	SE.play_sound("HitEnemy")
	if life <= 0:
		game.tomb_queue.append((global_position / 16).round() * 16)
		queue_free()
		SE.play_sound("KillEnemy")
		var scoreup = ScoreUp.create()
		game.add_child(scoreup)
		scoreup.global_position = global_position
		scoreup.score = price
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.material.set_shader_parameter('enabled', false)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	game.rusher_queue += 1
	queue_free()
