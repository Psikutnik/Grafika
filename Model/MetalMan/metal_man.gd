extends CharacterBody3D

var player = null
var state_machine

var health = 2.0
var speed = 9.0
const ATTACK_RANGE = 2

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collison = $CollisionShape3D

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Walk":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
	
		"Attack":
			pass
			# Navigation

	
	# Conditions
	anim_tree.set("parameters/conditions/Attack", _target_in_range())
	anim_tree.set("parameters/conditions/Walk", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam
	if health <= 0:
		collison.queue_free() # wsm to trzeba może maskamie trzeba bedzie zmienic
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
