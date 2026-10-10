extends CharacterBody2D
class_name Cleaner


@export var move_speed: float
@export var max_life: int
@export var price: int


@onready var game := get_tree().get_first_node_in_group("game") as Game
@onready var life := max_life
@onready var original_color := modulate

var move_horizontal_direction := 1


func _process(delta: float) -> void:
	$Sprite2D.flip_h = move_horizontal_direction < 0
	position.x += delta * move_horizontal_direction * move_speed


func _on_kill_all_tomb_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.queue_free()


func hurt():
	life -= 1
	modulate.v = original_color.v * life / max_life
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
	queue_free()
