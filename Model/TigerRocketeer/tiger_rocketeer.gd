extends CharacterBody3D

var player = null
var state_machine

var health = 2.0
var speed = 4.0
const ATTACK_RANGE = 2
var damage = 5
var is_attacking = false
var has_hit = false
var level_number
@export var player_path : NodePath
var is_dead = false
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collison = $CollisionShape3D
@onready var ouch: AudioStreamPlayer3D = $Ouch
@onready var attack: AudioStreamPlayer3D = $attack

var bullet = load("res://bullet.tscn")
var instance

@onready var rocket_barrel = $RocketBarrel

# Random walk variables
var random_walk_timer = 0.0
const RANDOM_WALK_INTERVAL = 8.0 # Change direction every 2 seconds
var current_random_target = null

func _ready():
	level_number = LevelFinish.level_number
	FileSave.enemy_update(level_number)
	if player_path.is_empty():
		player_path = $"../Player".get_path()
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	_set_new_random_target() # Set initial random target

func _process(delta):
	velocity = Vector3.ZERO

	match state_machine.get_current_node():
		"Walk":
			if not is_attacking:
				random_walk_timer -= delta
				# Update target if navigation finished, timer expired, or no current target
				if nav_agent.is_navigation_finished() or random_walk_timer <= 0 or current_random_target == null:
					# Rozpocznij atak przy zmianie kierunku
					is_attacking = true
					anim_tree.set("parameters/conditions/Attack", true)
					anim_tree.set("parameters/conditions/Walk", false)
					_set_new_random_target()
					random_walk_timer = RANDOM_WALK_INTERVAL
				
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * speed
				
				# Only update rotation if we're actually moving
				if velocity.length() > 0.1:
					rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
	
		"Attack":
			# Obracanie się w stronę gracza podczas ataku
			var direction_to_player = (player.global_position - global_position).normalized()
			var target_angle = atan2(-direction_to_player.x, -direction_to_player.z)
			rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)
			
			if not has_hit and state_machine.get_current_play_position() >= 0.5:  # 0.5 to około połowa animacji
				_hit_finished()
				has_hit = true
				
			# Sprawdź czy animacja ataku się zakończyła
			if state_machine.get_current_node() == "Attack" and state_machine.get_current_play_position() >= 0.9:
				is_attacking = false
				anim_tree.set("parameters/conditions/Attack", false)
				anim_tree.set("parameters/conditions/Walk", true)
	
	move_and_slide()

func _set_new_random_target():
	# Generate random direction and distance
	var random_angle = randf_range(0, 2 * PI)
	var random_distance = randf_range(5.0, 8.0)
	current_random_target = global_transform.origin + Vector3(
		sin(random_angle) * random_distance,
		0,
		cos(random_angle) * random_distance
	)
	nav_agent.set_target_position(current_random_target)

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	attack.play()
	# Oblicz dokładny kierunek do gracza
	var target_pos = player.global_position
	var barrel_pos = rocket_barrel.global_position
	var direction = (target_pos - barrel_pos).normalized()
	# Obracamy lufę w kierunku gracza
	rocket_barrel.look_at(target_pos, Vector3.UP)
	# Tworzymy pocisk
	var bullet_instance = bullet.instantiate()
	# Ustawiamy pozycję i rotację zgodnie z lufą
	bullet_instance.global_transform = rocket_barrel.global_transform
	# Dodajemy pocisk do sceny głównej (nie jako dziecko przeciwnika)
	get_tree().root.add_child(bullet_instance)

func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam
	ouch.play()
	if health <= 0&& not is_dead:
		is_dead = true
		FileSave.kill_update(level_number)
		anim_tree.set("parameters/conditions/Walk", false)
		anim_tree.set("parameters/conditions/Attack", false)
		anim_tree.set("parameters/conditions/Die", true)
		await get_tree().create_timer(2.0).timeout
		queue_free()
