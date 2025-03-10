extends GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	one_shot = true
	self.lifetime = lifetime
	if process_material:
		process_material = process_material.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init(pos1, pos2):
	global_position = pos1
		
	# Oblicz kierunek i długość smugi
	var direction = (pos2 - pos1).normalized()
	var distance = pos1.distance_to(pos2)

	# Ustaw proces material (np. ParticleProcessMaterial)
	var particle_material = process_material as ParticleProcessMaterial
	if particle_material:
		particle_material.direction = direction
		particle_material.initial_velocity_min = distance / lifetime
		particle_material.initial_velocity_max = distance / lifetime
		
	emitting = true
