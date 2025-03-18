extends Node3D

@onready var hit_rect = $UI/HitRect
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/CrosshairHit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	crosshair.position.x = get_viewport().size.x / 2 - 6
	crosshair.position.y = get_viewport().size.y / 2 - 6
	crosshair_hit.position.x = get_viewport().size.x / 2 - 6
	crosshair_hit.position.y = get_viewport().size.y / 2 - 6


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.3).timeout
	hit_rect.visible = false
