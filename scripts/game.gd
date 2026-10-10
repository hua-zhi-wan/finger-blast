extends Node2D
class_name Game


@export var tomb_prefab: PackedScene
@export var soldier_prefab: PackedScene

@export var rusher_prefab: PackedScene
var rusher_queue: int = 0

@export var cleaner_prefab: PackedScene
var cleaner_queue: int = 0

@export var tomb_count: int
var tomb_queue: Array[Vector2] = []

@export var wave_label: Label
@export var score_label: Label

var wave_index := 0
var score := 0

@onready var hand = get_tree().get_first_node_in_group('hand') as Hand


func _ready() -> void:
	var filled_grids = range(220 - tomb_count)
	filled_grids.append_array(range(-100, -100 - tomb_count, -1))
	filled_grids.shuffle()
	var index = 0
	for is_filled in filled_grids:
		if is_filled < 0:
			tomb_queue.append(Vector2(index % 20 * 16, (index / 20 + 1) * 16))
			await get_tree().create_timer(0.02).timeout
		index += 1
	
	$Timer.start()
	Engine.time_scale = 1


func _process(_delta: float) -> void:
	# Tomb Generate
	while not tomb_queue.is_empty():
		var tomb = tomb_prefab.instantiate() as Tomb
		$Tombs.add_child(tomb)
		tomb.global_position = tomb_queue.pop_front()
		tomb.target_y = floor(tomb.global_position.y)
	while rusher_queue > 0:
		var target_position = Vector2(16 * randi_range(0, 20), 0)
		var rusher = rusher_prefab.instantiate() as Rusher
		$Enemies.add_child(rusher)
		rusher.global_position = target_position
		rusher_queue -= 1
	while cleaner_queue > 0:
		var upper = randf() < 0.5
		var target_position = Vector2()
		var horizontal_position = [-1, 1].pick_random()
		if upper:
			target_position.y = randi_range(2, 10) * 16
		else:
			target_position.y = randi_range(11, 14) * 16
			horizontal_position = -1 if hand.global_position.x > 16 * 10 else 1
		target_position.x = (horizontal_position + 1) * 8 * 20
		var cleaner = cleaner_prefab.instantiate() as Cleaner
		$Enemies.add_child(cleaner)
		cleaner.global_position = target_position
		cleaner.move_horizontal_direction = -horizontal_position
		cleaner_queue -= 1


func get_score(v: int):
	score_label.offset_transform_scale = Vector2.ONE * 1.1
	create_tween().tween_property(score_label, 'offset_transform_scale', Vector2.ONE, 0.1)
	create_tween().tween_method(func(num):
		score_label.text = str(num)
	, score, score + v, 0.1)
	score += v
	
	if v > 10:
		create_tween().tween_method(func(a): 
			hand.camera.offset = Vector2.from_angle(randf() * PI * 2) * a
		, 2.0, 0, 0.05)


func _wave() -> void:
	if not $Enemies.get_children().is_empty():
		return
	if wave_index > 0:
		Engine.time_scale += 0.02
		wave_label.text = "WAVE: %d" % wave_index
	$RusherTimer.stop()
	$CleanerTimer.stop()
	
	var target_position = Vector2(16 * randi_range(0, 20), 0)
	var direction = [-1, 1].pick_random()
	
	if wave_index > 0:
		for entity: Node2D in $Tombs.get_children():
			if entity is Tomb:
				var tomb = entity as Tomb
				tomb.move_down()
	
	await get_tree().create_timer(1).timeout
	
	
	for i in range(randi_range(4, 8) + wave_index):
		var soldier = soldier_prefab.instantiate() as Soldier
		$Enemies.add_child(soldier)
		soldier.global_position = target_position
		soldier.move_horizontal_direction = direction
		await get_tree().create_timer(16.0 / soldier.move_speed).timeout
	
	$RusherTimer.start()
	$CleanerTimer.start()
	
	wave_index += 1


func _on_timer_timeout() -> void:
	_wave()


func _on_rusher_timer_timeout() -> void:
	if get_tree().get_node_count_in_group('soldier') > 0:
		if rusher_queue + get_tree().get_node_count_in_group('rusher') <= 0:
			rusher_queue += 1


func _on_cleaner_timer_timeout() -> void:
	if get_tree().get_node_count_in_group('soldier') > 0:
		cleaner_queue += 1
