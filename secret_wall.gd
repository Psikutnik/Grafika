extends Node3D

@onready var secret_wall: Node3D = $".."
var target_position: Vector3
@export var move_speed: float = 2.0  # Prędkość przesunięcia
@export var where: Vector3
var is_moving: bool = false

func interact():
	print("INTERAKCJA")
	if not is_moving:
		target_position = secret_wall.position + where
		is_moving = true

func _process(delta):
	if is_moving:
		secret_wall.position = secret_wall.position.lerp(target_position, move_speed * delta)
		# Zatrzymaj, gdy jest blisko celu
		if secret_wall.position.distance_to(target_position) < 0.1:
			secret_wall.position = target_position
			is_moving = false
