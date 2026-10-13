extends Control

@export var nickname_line_edit: LineEdit
@export var button_submit: Button
@export var button_refresh: Button
@export var tab_container: TabContainer
@export var scroll_weekly: ScrollContainer
@export var leaderboard_weekly_grid: GridContainer
@export var scroll_all_time: ScrollContainer
@export var leaderboard_all_time_grid: GridContainer

@export var your_record_color: Color


func _ready() -> void:
	button_submit.disabled = true
	button_refresh.disabled = true
	(func ():
		await get_tree().create_timer(10).timeout
		button_refresh.disabled = false).call()
	
	await LeaderboardManager.ensure_ready()
	print_debug("Leaderboard Ready.")
	nickname_line_edit.text = Global.nickname
	if Global.nickname.is_empty():
		nickname_line_edit.text = CheddaBoards.get_nickname()
	
	var weekly_rank = await LeaderboardManager.get_scoreboard("weekly")
	var all_time_rank = await LeaderboardManager.get_scoreboard("all-time")
	
	for grid: GridContainer in [leaderboard_all_time_grid, leaderboard_weekly_grid]:
		for c in grid.get_children():
			c.queue_free()
	
	var your_score := Global.score
	for kv in [[weekly_rank, leaderboard_weekly_grid, scroll_weekly, 0],
			[all_time_rank, leaderboard_all_time_grid, scroll_all_time, 1]]:
		tab_container.current_tab = kv[3] as int
		await get_tree().process_frame
		var rows = kv[0] as Array
		var grid = kv[1] as GridContainer
		var scroll = kv[2] as ScrollContainer
		var your_score_used := false
		var target_label: Control
		
		##MOCK
		#for i in range(randi_range(50, 100)):
			#_insert_record(grid, 999, "mock1", 10, false)
		#await get_tree().process_frame
		
		# GEN
		for row in rows:
			print_debug(row)
			if your_score > row.score and not your_score_used:
				_insert_record(grid, row.rank, "[YOU]", your_score, true)
				your_score_used = true
			target_label = _insert_record(grid, row.rank + (1 if your_score_used else 0), row.nickname, row.score, false)
		if not your_score_used:
			target_label = _insert_record(grid, -1, "[YOU]", your_score, true)
		
		##MOCK
		#for i in range(randi_range(50, 100)):
			#_insert_record(grid, 999, "mock2", 10, false)
		#await get_tree().process_frame
		
		# Scroll
		await get_tree().process_frame
		print_debug(target_label)
		scroll.set_deferred("scroll_vertical", target_label.position.y - 15 * 4)
	
	tab_container.current_tab = 0
	nickname_line_edit.grab_focus()
	button_submit.disabled = false


func _insert_record(grid: GridContainer, rank: int, nickname: String, score: int, is_your_score: bool) -> Control:
	var label = Label.new()
	grid.add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if rank < 0:
		label.text = "#???"
	else:
		label.text = "#%d" % rank
	label.text = label.text.lpad(8)
	if is_your_score:
		label.self_modulate = your_record_color
	
	label = Label.new()
	grid.add_child(label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	nickname = nickname.lpad(15)
	var score_str = var_to_str(score).lpad(8)
	label.text = "%s  -  %s" % [nickname, score_str]
	if is_your_score:
		label.self_modulate = your_record_color
	
	return label


func nickname_filter(nickname: String) -> String:
	var buffer = ""
	for c in nickname:
		if not "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_".contains(c):
			buffer += "_"
		else:
			buffer += c
	return buffer.substr(0, 15)


func _on_line_edit_text_changed(new_text: String) -> void:
	var real_nickname = nickname_filter(new_text)
	if real_nickname != new_text:
		var caret_column = nickname_line_edit.caret_column
		nickname_line_edit.text = real_nickname
		nickname_line_edit.caret_column = caret_column
	else:
		Global.nickname = new_text


func _on_button_submit_pressed() -> void:
	if nickname_line_edit.text:
		LeaderboardManager.submit_score(Global.score)
		button_submit.text = "WAITING"
		button_submit.disabled = true
		await LeaderboardManager.score_submitted
		button_submit.text = "OK!"


func _on_button_refresh_pressed() -> void:
	if is_inside_tree():
		get_tree().reload_current_scene()


func _on_button_close_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/title.tscn")
