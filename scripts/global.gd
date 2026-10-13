extends Node


var nickname: String
var score: int


func _ready() -> void:
	get_window().position += get_window().size / 2
	get_window().size *= 4
	get_window().position -= get_window().size / 2
