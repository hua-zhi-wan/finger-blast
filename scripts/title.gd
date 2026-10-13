extends Control

@export var button_play: Button

@export var button_fullscreen: Button
@onready var info_full_screen = tr("Full Screen")
@onready var info_windowed = tr("Windowed")

@export var button_sound: Button
@onready var info_se_on = tr("Sound On")
@onready var info_se_off = tr("Sound Off")
@onready var info_sfx_only = tr("SFX Only")


func _ready() -> void:
	SE.in_game(false)
	Global.score = 0
	Global.need_submit = false
	button_play.grab_focus()
	if not Global.setting_changed.is_connected(_on_setting_changed):
		Global.setting_changed.connect(_on_setting_changed)
	Global.read_all_settings()
	for button: Button in $Control.get_children():
		button.focus_entered.connect(SE.play_sound.bind("Click"))
		button.mouse_entered.connect(SE.play_sound.bind("Click"))
		button.pressed.connect(SE.play_sound.bind("Press"))


func _on_setting_changed(key: String, value):
	match key:
		"fullscreen":
			if value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				button_fullscreen.text = info_full_screen
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				button_fullscreen.text = info_windowed
		"sound":
			match value:
				0:
					AudioServer.set_bus_mute(0, true)
					AudioServer.set_bus_mute(2, false)
					button_sound.text = info_se_off
				1:
					AudioServer.set_bus_mute(0, false)
					AudioServer.set_bus_mute(2, false)
					button_sound.text = info_se_on
				2:
					AudioServer.set_bus_mute(0, false)
					AudioServer.set_bus_mute(2, true)
					button_sound.text = info_sfx_only



func _on_button_play_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_ranking_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/leaderboard_panel.tscn")


func _on_button_full_screen_pressed() -> void:
	Global.set_setting("fullscreen", not Global.get_setting("fullscreen"))


func _on_button_sound_pressed() -> void:
	Global.set_setting("sound", (Global.get_setting("sound") + 1) % 3)


func _on_button_language_pressed() -> void:
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	get_tree().quit()
