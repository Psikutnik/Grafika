extends MeshInstance3D

var alpha = 1.0
# Prefabrykat Decal do dziur (ustaw w edytorze lub ładuj dynamicznie)
@export var bullet_hole_decal: PackedScene = load("res://bullet_hole.tscn")

@onready var blood = $BloodSplatter
@onready var terrain = $TerrainParticles

func _ready():
	# Duplikujemy materiał i ustawiamy flagi dla przezroczystości
	var dup_mat = material_override.duplicate()
	material_override = dup_mat
	material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_override.albedo_color = Color(1, 1, 1, alpha)

func init(pos1, pos2):
	pass  # Możesz przywrócić rysowanie linii, jeśli nadal chcesz
	#var draw_mesh = ImmediateMesh.new()
	#mesh = draw_mesh
	#draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	#draw_mesh.surface_add_vertex(pos1)
	#draw_mesh.surface_add_vertex(pos2)
	#draw_mesh.surface_end()

func _process(delta):
	#alpha -= delta * 3.5
	if alpha <= 0:
		alpha = 0
		queue_free()
		return
	material_override.albedo_color.a = alpha

func trigger_particles(pos, gun_pos, on_enemy):
	if on_enemy:
		blood.position = pos
		blood.look_at(gun_pos)
		blood.emitting = true
	else:
		# Ustawiamy cząsteczki terenu
		terrain.position = pos
		terrain.look_at(gun_pos)
		terrain.emitting = true
		
		# Tworzymy dziurę po kuli
		if bullet_hole_decal:
			var decal = bullet_hole_decal.instantiate()
			get_tree().root.add_child(decal)  # Dodajemy do sceny
			decal.global_position = pos  # Ustawiamy pozycję w miejscu trafienia
			
			# Obracamy decal, aby pasował do powierzchni (opcjonalne)
			var normal = (gun_pos - pos).normalized()  # Wektor normalny w kierunku strzału
			decal.look_at(pos + normal, Vector3.UP)
			
			# Opcjonalnie: ustawiamy timer do usunięcia decala
			await get_tree().create_timer(10.0).timeout  # Usuwamy po 10 sekundach
			decal.queue_free()

func _on_timer_timeout() -> void:
	queue_free()
