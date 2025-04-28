extends Node3D

@onready var hit_rect = $UI/HitRect
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/CrosshairHit
@onready var hp_text = $UI/Hp
@onready var ammo_text = $UI/Ammo

var hp = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp_text.text = str(hp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_hit(damage) -> void:
	if hp <= 0:
		pass
	else:
		if damage > 0:
			hit_rect.visible = true
		hp = hp - damage
		hp_text.text = str(hp)
		await get_tree().create_timer(0.3).timeout
		hit_rect.visible = false
	


func _on_player_show_ammo(ammo) -> void:
	ammo_text.text = str(ammo)
