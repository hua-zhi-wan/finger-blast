extends Node2D
class_name Game


@export var tomb_prefab: PackedScene
@export var soldier_prefab: PackedScene

@export var rusher_prefab: PackedScene
var rusher_queue: int = 0

@export var cleaner_prefab: PackedScene
var cleaner_queue: int = 0

@export var swinger_prefab: PackedScene
var swinger_queue: int = 0

@export var tomb_count: int
var tomb_queue: Array[Vector2] = []

@export var wave_label: Label
@export var score_label: Label
@export var buff_label: Label

var wave_index := 0
var score := 0

@onready var hand = get_tree().get_first_node_in_group('hand') as Hand
var buff: StringName = &""
var buff_timer: float

@export var heart_container: Container
@export var heart_count: Container
@export var heart_node: Control
@export var heart_label: Label
var heart: int = 3

var score_bar: int = 10000


func _ready() -> void:
	heart_node.get_parent().remove_child(heart_node)
	update_heart()
	remove_buff()
	Engine.time_scale = 1
	SE.in_game(true)
	if OS.has_feature("steam"):
		score += 1
	
	await fill_tomb(tomb_count)
	$MainTimer.start()


func _process(delta: float) -> void:
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
			target_position.y = randi_range(2, 9) * 16
		else:
			target_position.y = randi_range(10, 14) * 16
			horizontal_position = -1 if hand.global_position.x > 16 * 10 else 1
		target_position.x = (horizontal_position + 1) * 8 * 19
		var cleaner = cleaner_prefab.instantiate() as Cleaner
		$Enemies.add_child(cleaner)
		cleaner.global_position = target_position
		cleaner.move_horizontal_direction = -horizontal_position
		cleaner_queue -= 1
	while swinger_queue > 0:
		var target_position = Vector2()
		var horizontal_position = -1 if hand.global_position.x > 16 * 10 else 1
		target_position.x = (horizontal_position + 1) * 8 * 19
		target_position.y = randi_range(11, 14) * 16
		var swinger = swinger_prefab.instantiate() as Swinger
		$Enemies.add_child(swinger)
		swinger.global_position = target_position
		swinger.move_horizontal_direction = -horizontal_position
		swinger.move_vertical_diretion = [-1, 1].pick_random()
		swinger_queue -= 1
	if buff_timer > 0:
		buff_timer -= delta
		var buff_str
		match buff:
			Buff.MELEE: buff_str =  tr("MELEE")
			Buff.SWIFT: buff_str =  tr("RAPID")
			Buff.PRECISE: buff_str =  tr("PRECISE")
			Buff.FAN: buff_str =  tr("SPREAD")
		buff_label.text = "%s:%d" % [buff_str, ceili(buff_timer)]
		if buff_timer <= 0:
			remove_buff()


func fill_tomb(n: int):
	if n <= 0:
		return
	var filled_grids = range(220 - n)
	filled_grids.append_array(range(-100, -100 - n, -1))
	filled_grids.shuffle()
	for tomb: Tomb in get_tree().get_nodes_in_group('tomb'):
		var i = roundi(tomb.global_position.x) + roundi(tomb.global_position.y) * 20
		if i < filled_grids.size():
			filled_grids[i] = 0
	var index = 0
	for is_filled in filled_grids:
		if is_filled < 0:
			var tomb_target_position = Vector2(index % 20 * 16, (index / 20 + 1) * 16)
			tomb_queue.append(tomb_target_position)
			await get_tree().create_timer(0.02, false).timeout
		index += 1


func get_score(v: int):
	score_label.offset_transform_scale = Vector2.ONE * 1.1
	create_tween().tween_property(
		score_label, 'offset_transform_scale', Vector2.ONE, 0.1)
	create_tween().tween_method(func(num):
		score_label.text = str(num)
	, score, score + v, 0.1)
	score += v
	
	if v > 10:
		create_tween().tween_method(func(a): 
			hand.camera.offset = Vector2.from_angle(randf() * PI * 2) * a
		, 2.0, 0, 0.05)
	
	if score >= score_bar:
		score_bar += 20000
		heart += 1
		SE.play_sound("HeartUp")
		update_heart()
		heart_count.offset_transform_scale = Vector2.ONE * 1.2
		create_tween().tween_property(
			heart_count, 'offset_transform_scale', Vector2.ONE, 0.1)


func get_buff(buff_name: StringName):
	buff = buff_name
	buff_timer = 8


func remove_buff():
	buff = &""
	buff_timer = 0
	buff_label.text = ""


func update_heart():
	for child: Node in heart_container.get_children():
		child.queue_free()
	if heart > 3:
		heart_label.text = "x%d" % heart
		heart_container.add_child(heart_node.duplicate())
	else:
		heart_label.text = ""
		for i in range(heart):
			heart_container.add_child(heart_node.duplicate())


func _wave() -> void:
	var enemy_count = 0
	for tag in ['soldier', 'rusher', 'swinger', 'cleaner']:
		enemy_count += get_tree().get_node_count_in_group(tag)
	if enemy_count > 0:
		return
	wave_index += 1
	if wave_index > 1:
		Engine.time_scale = clampf(Engine.time_scale + 0.02, 1, 1.8)
		wave_label.text = "%s:%d" % [tr("WAVE"), wave_index]
	
	for timer: Timer in get_tree().get_nodes_in_group('game_timer'):
		timer.stop()
	
	if wave_index > 1:
		for entity: Node2D in $Tombs.get_children():
			if entity is Tomb:
				var tomb = entity as Tomb
				tomb.move_down()
		await get_tree().create_timer(1, false).timeout
	
	var total_tomb = get_tree().get_node_count_in_group('tomb')
	if total_tomb < tomb_count * 0.5:
		await fill_tomb(tomb_count - total_tomb)
	
	var soldier_count = randi_range(4, 9) + wave_index
	var max_soldier_count := randi_range(12, 16)
	spawn_soldiers(mini(soldier_count, max_soldier_count), true)
	
	for timer: Timer in get_tree().get_nodes_in_group('game_timer'):
		timer.start()
	
	while soldier_count - max_soldier_count > 0:
		await get_tree().create_timer(4, false).timeout
		soldier_count -= max_soldier_count
		await spawn_soldiers(mini(soldier_count, max_soldier_count), true)


func spawn_soldiers(count: int, buff_flag: bool):
	var target_position = Vector2(16 * randi_range(0, 20), 0)
	var direction = [-1, 1].pick_random()
	var soldier_count_array = range(count)
	var buff_index = soldier_count_array.pick_random()
	for i in soldier_count_array:
		var soldier = soldier_prefab.instantiate() as Soldier
		$Enemies.add_child(soldier)
		soldier.global_position = target_position
		soldier.move_horizontal_direction = direction
		soldier.has_buff = (i == buff_index) and buff_flag
		await get_tree().create_timer(16.0 / soldier.move_speed, false).timeout



func _on_timer_timeout() -> void:
	_wave()


func _on_rusher_timer_timeout() -> void:
	if wave_index >= 2:
		if get_tree().get_node_count_in_group('soldier') > 0:
			var max_rusher = 1
			if rusher_queue + get_tree().get_node_count_in_group('rusher') < max_rusher:
				rusher_queue += 1


func _on_cleaner_timer_timeout() -> void:
	if wave_index >= 3:
		if get_tree().get_node_count_in_group('soldier') > 0:
			cleaner_queue += 1


func _on_swinger_timer_timeout() -> void:
	if get_tree().get_node_count_in_group('soldier') > 0:
		var max_swinger = 0
		if wave_index >= 4:
			max_swinger += 1
		if wave_index >= 8:
			max_swinger += 1
		if get_tree().get_node_count_in_group('swinger') < max_swinger:
			swinger_queue += 1
