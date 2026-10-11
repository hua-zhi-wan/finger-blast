extends Area2D
class_name Bullet


@export var move_speed_vector: Vector2
@export var effect_prefab: PackedScene
@export var life: float

@onready var game = get_tree().get_first_node_in_group('game') as Game

var is_used: bool = false


func _process(delta: float) -> void:
	position += delta * move_speed_vector
	if game.buff == Buff.PRECISE:
		global_position.x = game.hand.marker_3.global_position.x
	
	life -= delta
	if game.buff == Buff.MELEE and life < 0:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not is_used and body.has_method("hurt"):
		is_used = true
		body.hurt()
		var eff = effect_prefab.instantiate()
		get_parent().add_child(eff)
		eff.global_position.x = self.global_position.x
		eff.global_position.y = body.global_position.y + 16
		queue_free()
