extends CharacterBody2D
class_name Hand


@onready var game = get_tree().get_first_node_in_group("game") as Game

@export var camera: Camera2D

@export var move_speed: float
@export var bullet_prefab: PackedScene
@export var min_y: float
@export var fire_cooldown: float
@export var swift_fire_cooldown: float
@export var precise_fire_cooldown: float
@export var fan_fire_cooldown: float
@export var melee_fire_cooldown: float

@export var marker_melee: Marker2D
@export var marker_2: Marker2D
@export var marker_3: Marker2D

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
		
		global_position = global_position.clamp(Vector2(0, 160), Vector2(16*19, 16*14))
		
		# Shoot
		if Input.is_action_pressed("fire") and fire_cooldown_timer < 0:
			var bullet_position
			match game.buff:
				Buff.PRECISE, Buff.FAN:
					bullet_position = marker_3.global_position
				Buff.MELEE:
					bullet_position = marker_melee.global_position
				_:
					bullet_position = marker_2.global_position
			match (game.buff):
				Buff.MELEE: fire_cooldown_timer = melee_fire_cooldown
				Buff.PRECISE: fire_cooldown_timer = precise_fire_cooldown
				Buff.FAN: fire_cooldown_timer = fan_fire_cooldown
				Buff.SWIFT: fire_cooldown_timer = swift_fire_cooldown
				_: fire_cooldown_timer = fire_cooldown
			if game.buff == Buff.FAN:
				for dir in [-0.03, -0.01, 0.01, 0.03]:
					dir = dir * PI * 2
					var bullet = bullet_prefab.instantiate() as Bullet
					game.add_child(bullet)
					bullet.global_position = bullet_position
					bullet.move_speed_vector = bullet.move_speed_vector.rotated(dir)
			else:
				var bullet = bullet_prefab.instantiate() as Bullet
				game.add_child(bullet)
				bullet.global_position = bullet_position
			SE.play_sound('Shoot')
			$AnimationPlayer.play("shoot")
		fire_cooldown_timer -= delta
	
	if game.buff:
		$AnimatedSprite2D.self_modulate = Buff.BUFF_TO_COLOR[game.buff]
		$AnimatedSprite2D.play(game.buff)
	else:
		$AnimatedSprite2D.self_modulate = Color.WEB_GRAY
		$AnimatedSprite2D.play("swift")


func dead():
	Engine.time_scale = 0.1
	is_dead = true
	$Camera2D.limit_bottom += 16
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
