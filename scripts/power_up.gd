extends Area2D
class_name Buff


@export var move_speed: float
@export var buff: StringName
@export var price: int

@onready var game := get_tree().get_first_node_in_group("game") as Game

const SWIFT = &"swift"
const PRECISE = &"precise"
const FAN = &"fan"
const MELEE = &"melee"

static var BUFF_TO_COLOR = {
	SWIFT: Color.from_string("#57b2ff", Color.WHITE),
	PRECISE: Color.from_string("#63c259", Color.WHITE),
	FAN: Color.from_string("#65e2fb", Color.WHITE),
	MELEE: Color.from_string("#ff7085", Color.WHITE)
}


func _ready() -> void:
	$Sprite2D.self_modulate = BUFF_TO_COLOR.get(buff, Color.WHITE)


func _process(delta: float) -> void:
	position.y += move_speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	game.get_buff(buff)
	var scoreup = ScoreUp.create()
	game.add_child(scoreup)
	scoreup.global_position = global_position
	scoreup.score = price
	queue_free()
