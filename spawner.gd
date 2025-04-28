extends Node3D

const METAL_MAN = preload("res://Model/MetalMan/metal_man.tscn")

func _physics_process(delta):
	if Input.is_action_just_pressed("spawn"):
			var instance = METAL_MAN.instantiate()
			instance.global_transform = global_transform
			get_tree().current_scene.add_child(instance)
