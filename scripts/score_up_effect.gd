extends Node2D
class_name ScoreUp


@onready var game = get_tree().get_first_node_in_group('game') as Game

var score: int:
	set(v):
		score = v
		$Label.text = "+%d" % score
		game.get_score(score)


static func create() -> ScoreUp:
	var prefab = load("res://scenes/score_up_effect.tscn") as PackedScene
	var scoreup = prefab.instantiate() as ScoreUp
	return scoreup
