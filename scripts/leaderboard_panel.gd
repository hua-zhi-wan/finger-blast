extends Control

@export var title1: Label
@export var title2: Label

@export var nickname_line_edit: LineEdit
@export var button_submit: Button
@export var button_refresh: Button
@export var button_close: Button
@export var tab_container: TabContainer
@export var scroll_weekly: ScrollContainer
@export var leaderboard_weekly_grid: GridContainer
@export var scroll_all_time: ScrollContainer
@export var leaderboard_all_time_grid: GridContainer

@export var your_record_color: Color


func _ready() -> void:
	SE.in_game(true)
	for button: Button in [button_close, button_refresh, button_submit]:
		button.focus_entered.connect(SE.play_sound.bind("Click"))
		button.mouse_entered.connect(SE.play_sound.bind("Click"))
		button.pressed.connect(SE.play_sound.bind("Press"))
	tab_container.tab_hovered.connect(func(_i): SE.play_sound("Click"))
	tab_container.tab_changed.connect(func(_i): SE.play_sound("Press"))
	
	[title1, title2][1 if Global.need_submit else 0].hide()
	if not Global.need_submit:
		button_submit.hide()
		nickname_line_edit.hide()

	button_close.grab_focus()
	button_close.disabled = true
	button_submit.disabled = true
	button_refresh.disabled = true
	(func ():
		await get_tree().create_timer(1).timeout
		button_close.disabled = false
		await get_tree().create_timer(10).timeout
		button_refresh.disabled = false).call()
	
	await LeaderboardManager.ensure_ready()
	print_debug("Leaderboard Ready.")
	nickname_line_edit.text = Global.nickname
	if Global.nickname.is_empty():
		nickname_line_edit.text = CheddaBoards.get_nickname()
	
	var your_score := Global.score
	var your_name := tr("[YOU]")
	for kv in [["weekly", leaderboard_weekly_grid, scroll_weekly, 0],
			["all-time", leaderboard_all_time_grid, scroll_all_time, 1]]:
		#var rows = kv[0] as Array
		var rows = await LeaderboardManager.get_scoreboard(kv[0])
		var original_tab = tab_container.current_tab
		tab_container.current_tab = kv[3] as int
		var grid = kv[1] as GridContainer
		var scroll = kv[2] as ScrollContainer
		var your_score_used := false
		var target_label: Control
		
		for child: Control in grid.get_children():
			child.queue_free()
		
		## MOCK
		#for i in range(randi_range(50, 100)):
			#_insert_record(grid, 999, "mock1", 10, false)
		#await get_tree().process_frame
		
		# GEN
		for row in rows:
			if Global.need_submit and your_score > row.score and not your_score_used:
				_insert_record(grid, row.rank, your_name, your_score, true)
				your_score_used = true
			target_label = _insert_record(grid, row.rank + (1 if your_score_used else 0), row.nickname, row.score, false)
		if Global.need_submit and not your_score_used:
			target_label = _insert_record(grid, -1, your_name, your_score, true)
		
		## MOCK
		#for i in range(randi_range(50, 100)):
			#_insert_record(grid, 999, "mock2", 10, false)
		#await get_tree().process_frame
		
		# Scroll
		await get_tree().process_frame
		if not target_label and Global.nickname:
			for label: Label in grid.get_children():
				if label and label.text.contains(Global.nickname):
					target_label = label
					print_debug("Find Target label.", target_label)
					break
		if target_label:
			scroll.set_deferred("scroll_vertical", target_label.position.y - 15 * 4)
	
		tab_container.current_tab = original_tab
	
	if Global.need_submit:
		if Global.nickname:
			nickname_line_edit.grab_focus()
		else:
			button_submit.grab_focus()
	button_submit.disabled = false


func _insert_record(grid: GridContainer, rank: int, nickname: String, score: int, is_your_score: bool) -> Control:
	var rank_str = "#???"
	if rank > 0:
		rank_str = "#%d" % rank
	rank_str = rank_str.lpad(8)
	nickname = nickname.lpad(15)
	var score_str = var_to_str(score).lpad(8)
	
	var label: Label
	for s: String in [rank_str, nickname, "  -  ", score_str]:
		label = Label.new()
		grid.add_child(label)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.text = s
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


func _on_button_submit_pressed() -> void:
	if nickname_line_edit.text:
		Global.nickname = nickname_line_edit.text
		if Global.nickname and CheddaBoards.get_nickname() != Global.nickname:
			CheddaBoards.change_nickname(Global.nickname)
		LeaderboardManager.submit_score(Global.score)
		button_submit.text = tr("WAITING")
		button_submit.disabled = true
		await LeaderboardManager.score_submitted
		button_submit.text = tr("OK!")
		Global.need_submit = false


func _on_button_refresh_pressed() -> void:
	if is_inside_tree():
		get_tree().reload_current_scene()


func _on_button_close_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/title.tscn")
