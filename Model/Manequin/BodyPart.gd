extends Area3D

@export var damage := 1.0

signal body_part_hit(dam)

func hit(weaponDamage: float):
	emit_signal("body_part_hit", damage * weaponDamage)
