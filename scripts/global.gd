extends Node


signal setting_changed(key: String, value: Variant)

var nickname: String:
	get(): return _config.get_value(CONFIG_DEFAULT_SECTION, "nickname", "")
	set(value):
		set_setting("nickname", value)
var score: int
var need_submit: bool = false


const CONFIG_PATH := "user://settings.cfg"
const CONFIG_DEFAULT_SECTION := "game"
var _config_kv = {
	'fullscreen': false,
	'sound': 1,
	'language': 'en_US',
	'nickname': '',
}
var _config := ConfigFile.new()


func _ready() -> void:
	get_window().position += get_window().size / 2
	get_window().size *= 4
	get_window().position -= get_window().size / 2
	
	var err := _config.load(CONFIG_PATH)
	if err != OK:
		for key in _config_kv:
			_config.set_value(CONFIG_DEFAULT_SECTION, key, _config_kv[key])
		save()


func read_all_settings():
	for key in _config_kv:
		setting_changed.emit(key, _config.get_value(CONFIG_DEFAULT_SECTION, key))


func save() -> void:
	var err := _config.save(CONFIG_PATH)
	if err != OK:
		push_error("Config Saved Failed: %s" % error_string(err))


func get_setting(key: String):
	return _config.get_value(CONFIG_DEFAULT_SECTION, key)


func set_setting(key: String, value):
	_config.set_value(CONFIG_DEFAULT_SECTION, key, value)
	setting_changed.emit(key, value)
	save()
