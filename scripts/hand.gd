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

@onready var last_click_position: Vector2 = get_global_mouse_position()
@onready var last_position: Vector2 = global_position


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		last_click_position = get_global_mouse_position()
		last_position = global_position


func _process(delta: float) -> void:
	var move_vector = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	) * move_speed * delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		move_vector = (get_global_mouse_position() - last_click_position) - (global_position - last_position)
	
	if not is_dead:
		# Move
		move_and_collide(Vector2(move_vector.x, 0))
		move_and_collide(Vector2(0, move_vector.y))
		
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
	SE.play_sound("HandHit")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/title.tscn")
	else:
		print_debug(game)


func _dead_sound():
	SE.play_sound("Explosion")


func _on_hurt_area_body_entered(_body: Node2D) -> void:
	#return
	dead()
