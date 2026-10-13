extends Control


var is_sdk_ready: bool = false

signal sdk_ready()
signal scoreboard(arr: Array)
signal leaderboard(arr: Array)
signal score_submitted


func _ready():
	CheddaBoards.set_api_key("cb_finger-blast_b944e5e8f3d9082fb5cd31a4fbb57394")
	CheddaBoards.set_game_id("finger-blast")

	CheddaBoards.leaderboard_loaded.connect(_on_leaderboard)
	CheddaBoards.scoreboard_loaded.connect(_on_scoreboard)
	CheddaBoards.score_submitted.connect(func(_a, _b):
		score_submitted.emit())
	CheddaBoards.nickname_error.connect(func(info: String):
		print_debug("nickname_error: " + info))


	await CheddaBoards.wait_until_ready()
	CheddaBoards.login_anonymous()
	is_sdk_ready = true
	sdk_ready.emit()
	print_debug("Leaderboard SDK Ready.")


func ensure_ready():
	if is_sdk_ready:
		return
	await sdk_ready


func _on_scoreboard(scoreboard_id, config, entries: Array):
	print_debug("_on_scoreboard", scoreboard_id, config)
	print_debug(entries)
	scoreboard.emit(entries)


func submit_score(score: int):
	if is_sdk_ready:
		CheddaBoards.submit_score(score)


func get_scoreboard(scoreboard_id: String) -> Array:
	if is_sdk_ready:
		CheddaBoards.get_scoreboard(scoreboard_id, 1000)
		return await scoreboard
	return []


# Deprecated
func _on_leaderboard(entries: Array):
	for e in entries:
		print_debug("#%d %s - %d" % [e.rank, e.nickname, e.score])
	leaderboard.emit(entries)


func get_leaderboard() -> Array:
	if is_sdk_ready:
		CheddaBoards.get_leaderboard("score", 1000)
		return await leaderboard
	return []
