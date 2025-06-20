extends Area3D

@export var delay = 0.1
@export var thing: PackedScene  # Scena do zrespienia, ustawiana w edytorze
@export var place: Array[Node3D]  # Lista węzłów określających pozycje, ustawiana w edytorze
var triggered = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and triggered == false:
		triggered = true
		# Sprawdź, czy thing i place są ustawione
		if thing and place.size() > 0:
			for p in place:
				if p:  # Sprawdź, czy węzeł place istnieje
					var thing_instance = thing.instantiate()
					get_tree().current_scene.add_child(thing_instance) # Dodaj do sceny
					thing_instance.global_position = p.global_position  # Ustaw pozycję
					await get_tree().create_timer(delay).timeout
