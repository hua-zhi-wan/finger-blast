extends Area2D


@export var move_speed: float
@export var effect_prefab: PackedScene

var is_used: bool = false


func _process(delta: float) -> void:
	position.y -= delta * move_speed


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
