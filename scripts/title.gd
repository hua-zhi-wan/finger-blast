extends Control

@export var button_play: Button
@export var button_fullscreen: Button
@export var button_sound: Button

@export var buttons: Array[Button]

func _ready() -> void:
	Engine.time_scale = 1.0
	
	SE.in_game(false)
	Global.score = 0
	Global.need_submit = false
	
	button_play.grab_focus()
	if not Global.setting_changed.is_connected(_on_setting_changed):
		Global.setting_changed.connect(_on_setting_changed)
	Global.read_all_settings()
	refresh_ui()
	for button: Button in buttons:
		button.focus_entered.connect(SE.play_sound.bind("Click"))
		button.mouse_entered.connect(SE.play_sound.bind("Click"))
		button.pressed.connect(SE.play_sound.bind("Press"))


func _on_setting_changed(key: String, value):
	match key:
		"fullscreen":
			if value:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				button_fullscreen.text = tr("Full Screen")
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				button_fullscreen.text = tr("Windowed")
		"sound":
			match value:
				0:
					AudioServer.set_bus_mute(0, true)
					AudioServer.set_bus_mute(2, false)
					button_sound.text = tr("Sound Off")
				1:
					AudioServer.set_bus_mute(0, false)
					AudioServer.set_bus_mute(2, false)
					button_sound.text = tr("Sound On")
				2:
					AudioServer.set_bus_mute(0, false)
					AudioServer.set_bus_mute(2, true)
					button_sound.text = tr("SFX Only")
		"language":
			TranslationServer.set_locale(value)


func refresh_ui():
		if Global.get_setting("fullscreen"):
			button_fullscreen.text = tr("Full Screen")
		else:
			button_fullscreen.text = tr("Windowed")
		match Global.get_setting("sound"):
			0: button_sound.text = tr("Sound Off")
			1: button_sound.text = tr("Sound On")
			2: button_sound.text = tr("SFX Only")



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

@onready var languages = TranslationServer.get_loaded_locales()
func _on_button_language_pressed() -> void:
	var locale = Global.get_setting("language") as String
	Global.set_setting("language", languages.get((languages.find(locale) + 1) % languages.size()))
	refresh_ui()


func _on_button_quit_pressed() -> void:
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/about.tscn")
