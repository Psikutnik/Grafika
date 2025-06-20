extends Node3D

const SPEED = 60.0
const BULLET_DAMAGE = 15


@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D


func _process(delta):
	position += transform.basis * Vector3(0,0, -SPEED) * delta
	if ray.is_colliding():
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit(BULLET_DAMAGE* 0.25)
		if ray.get_collider().is_in_group("player"):
			ray.get_collider().hit(Vector3.ZERO,BULLET_DAMAGE)
	
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout():
	queue_free()
