extends Node


func _ready():
	# Credentials must come before any other CheddaBoards call.
	CheddaBoards.set_api_key("cb_finger-blast_b944e5e8f3d9082fb5cd31a4fbb57394")
	CheddaBoards.set_game_id("finger-blast")

	# Connect the leaderboard signal ONCE here — not inside a function,
	# or you'll reconnect it every time you open the board.
	CheddaBoards.leaderboard_loaded.connect(_on_leaderboard)

	# Wait for the SDK, then log in.
	# submit_score fails until login has completed.
	await CheddaBoards.wait_until_ready()
	CheddaBoards.login_anonymous()   # no name — see note below


# Call from YOUR game-over code, with the final score and streak.
func _on_game_over(score: int, streak: int):
	CheddaBoards.submit_score(score, streak)


# Call when you want to show the board (e.g. a button press).
func show_leaderboard():
	CheddaBoards.get_leaderboard("score", 100)


# Fires when get_leaderboard() returns. Connected once, in _ready().
func _on_leaderboard(entries: Array):
	for e in entries:
		print_debug("#%d %s - %d" % [e.rank, e.nickname, e.score])
