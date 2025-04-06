extends Area3D

#zastrzeżenie co do world patha jest takie że trzeba je ustawiać przy nowej instancji (tak jak u przeciwników)
@export var player_path : NodePath
var player = null
var amount = 10
@export var type = 'G'
@onready var anim = $MeshInstance3D/AnimationPlayer

func _ready():
	player = get_node(player_path)
	await get_tree().create_timer(randf_range(0.1, 1.0)).timeout
	anim.play("Default")

func _on_body_entered(body: Node3D) -> void:
	player.collect_ammo(type,amount)
	#player.collect_weapon(1,true)
	queue_free()
