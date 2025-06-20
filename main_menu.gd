extends Control
@onready var menu_nodes: Control = $MenuNodes
@onready var settings: Control = $Settings


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")


func _on_options_pressed() -> void:
	menu_nodes.visible = false
	settings.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()
