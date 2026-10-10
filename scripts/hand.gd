extends CharacterBody2D
class_name Hand

@onready var game = get_tree().get_first_node_in_group("game") as Game

@export var camera: Camera2D

@export var move_speed: float
@export var bullet_prefab: PackedScene
@export var min_y: float
@export var fire_cooldown: float

var fire_cooldown_timer: float
var is_dead: bool


func _process(delta: float) -> void:
	var move_vector = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	if not is_dead:
		# Move
		move_and_collide(Vector2(move_vector.x, 0) * move_speed * delta)
		move_and_collide(Vector2(0, move_vector.y) * move_speed * delta)

		# Shoot
		if Input.is_action_pressed("fire") and fire_cooldown_timer < 0:
			var bullet = bullet_prefab.instantiate() as Area2D
			game.add_child(bullet)
			bullet.global_position = $Marker2D.global_position
			fire_cooldown_timer = fire_cooldown
			SE.play_sound('Shoot')
			$AnimationPlayer.play("shoot")
		fire_cooldown_timer -= delta
		
	global_position = global_position.clamp(Vector2(0, 160), Vector2(16*19, 16*14))


func dead():
	Engine.time_scale = 0.1
	is_dead = true
	$AnimationPlayer.play("dead")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1
	game.get_tree().change_scene_to_file("res://scenes/title.tscn")

func _dead_sound():
	SE.play_sound("Explosion")


func _on_hurt_area_body_entered(_body: Node2D) -> void:
	#return
	dead()
