extends StaticBody2D
class_name Tomb

@export var move_speed: float
@export var max_life: int
@export var max_y: int
@export var price: int

@onready var original_color := modulate
@onready var life := max_life
@onready var game = get_tree().get_first_node_in_group('game') as Game

var target_y: int


func _ready() -> void:
	$AnimatedSprite2D.frame = randi_range(0, $AnimatedSprite2D.sprite_frames.get_frame_count("default"))
	$AnimatedSprite2D.flip_h = randf() < 0.5
	$AnimatedSprite2D.scale = Vector2.ZERO
	await get_tree().create_timer(randf_range(0, 0.2)).timeout
	$AnimationPlayer.play("spawn")


func _process(delta: float) -> void:
	if target_y > global_position.y:
		global_position.y = move_toward(global_position.y, target_y, delta * move_speed)
	
	if target_y >= max_y:
		queue_free()


func move_down() -> void:
	target_y += 16


func hurt() -> void:
	life -= 1
	$AnimatedSprite2D.material.set_shader_parameter('dissolve_amount', remap(life, 0, max_life, 1, 0))
	var offset = $AnimatedSprite2D.offset
	create_tween().tween_method(func(val):
		$AnimatedSprite2D.offset = offset + Vector2.from_angle(randf() * PI * 2) * val
	,2, 0, 0.1)
	SE.play_sound("HitTomb")
	if life <= 0:
		var scoreup = ScoreUp.create()
		game.add_child(scoreup)
		scoreup.global_position = global_position
		scoreup.score = price
		queue_free()
