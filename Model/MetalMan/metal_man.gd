extends CharacterBody3D

var player = null
var state_machine

var health = 5.0
var speed = 12.0
const ATTACK_RANGE = 2
var damage = 15
var is_dead = false
var hunting = false
@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collison = $CollisionShape3D
@onready var ouch: AudioStreamPlayer3D = $Ouch
var level_number = 1


func _ready():
	level_number = LevelFinish.level_number
	FileSave.enemy_update(level_number)
	player = get_node(player_path)
	if player_path.is_empty():
		player_path = $"../Player".get_path()
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
	
		"Default":
			velocity.y -= 3 * delta
			# Navigation
	
	# Conditions
	if hunting:
		anim_tree.set("parameters/conditions/Attack", _target_in_range())
		anim_tree.set("parameters/conditions/Walk", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, damage)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	hunting = true
	health -= dam
	if randf() < 1:
		ouch.play()
	if health <= 0 && not is_dead: 
		is_dead = true
		FileSave.kill_update(level_number)
		
		anim_tree.set("parameters/conditions/die", true)
		collison.disabled = true
		await get_tree().create_timer(4.0).timeout
		queue_free()


func _on_detection_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		hunting = true
