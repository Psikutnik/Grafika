extends Node3D

@export var radius: float = 5.0  # Promień okręgu
@export var speed: float = -2.0   # Prędkość ruchu po okręgu (radiany na sekundę)
@export var height: float = 0.0  # Wysokość w osi Y
@export var center: Node3D       # Węzeł określający centrum okręgu
@export var rotation_speed: float = 3.0  # Prędkość obrotu wokół osi Y (radiany na sekundę)
var angle: float = 0.0           # Aktualny kąt dla ruchu po okręgu

func _process(delta: float) -> void:
	if center:  # Sprawdź, czy centrum jest ustawione
		# Poprzednia pozycja (do obliczenia kierunku ruchu)
		var prev_position = global_position
		
		# Ruch po okręgu
		angle += speed * delta
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		global_position = center.global_position + Vector3(x, height, z)
		
		# Oblicz kierunek ruchu (wektor styczny)
		var direction = (global_position - prev_position).normalized()
		if direction.length() > 0:  # Upewnij się, że kierunek jest niezerowy
			# Skieruj obiekt wzdłuż kierunku ruchu
			look_at(global_position - direction, Vector3.UP)
		
		# Dodaj obrót wokół osi Y
		rotate_y(rotation_speed * delta)
