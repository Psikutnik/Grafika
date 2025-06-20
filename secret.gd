extends Area3D


@onready var text: Label = $FOUND/text
var level_number
var is_found = false

func _ready() -> void:
	level_number = LevelFinish.level_number
	FileSave.secret_update(level_number)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" && not is_found:
		is_found = true
		FileSave.secret_found_update(level_number)
		text.visible = true
		await get_tree().create_timer(2.0).timeout
		text.visible = false
