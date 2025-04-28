extends Control
@onready var fullscreen: CheckButton = $MarginContainer/VBoxContainer/Fullscreen
@onready var menu_nodes: Control = $"../MenuNodes"


func _ready():
	$MarginContainer/VBoxContainer/Volume.value = FileSave.volume
	fullscreen.button_pressed = FileSave.fullscreen
	if FileSave.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_value_changed(value: float) -> void:
	var volume_db = -80 if value == 0 else lerp(-30, 0, value / 100.0)
	AudioServer.set_bus_volume_db(0, volume_db)
	FileSave.volume = value


func _on_resolutions_item_selected(index: int) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	fullscreen.button_pressed = false
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2:
			DisplayServer.window_set_size(Vector2i(1024,768))
	get_window().position = (DisplayServer.screen_get_size() - get_window().size) / 2
	FileSave.resolution = index


func _on_fullscreen_pressed() -> void:
	FileSave.fullscreen = !FileSave.fullscreen
	if FileSave.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_pressed() -> void:
	visible = false
	menu_nodes.visible = true
