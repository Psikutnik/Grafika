extends CharacterBody3D

var speed
const WALK_SPEED = 6.5 #5
const SPRINT_SPEED = 32.0 #8
const JUMP_VELOCITY = 4.8 
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

#scale
var isCrouch = false

# Bullets
var bullet = preload("res://bullet.tscn")
var bullet_trail = load("res://bullet_trail.tscn")
var instance

# Weapon switching
enum weapons {
	BALL,
	PRISM
}

var weapon_availability = {
	weapons.BALL: true,
	weapons.PRISM: false
}

var weapon = weapons.PRISM
var can_shoot = true
@onready var weapon_switching = $Head/Camera3D/WeaponSwitching

# Signal
signal player_hit
signal show_ammo

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var audio = $Head/AudioStreamPlayer3D
@onready var main_ray = $Head/Camera3D/MainRay
@onready var ray_end = $Head/Camera3D/RayEnd
@onready var shaker: ShakerComponent3D = $Head/Camera3D/ShakerComponent3D
#GunBall
var gun_ammo = 100
var bullets_in_chamber = 0
@onready var gun_anim = $Head/Camera3D/GunBall/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/GunBall/RayCast3D
@onready var gun_flash = $Head/Camera3D/GunBall/MuzzleFlash
# GunPrism
var prism_ammo = 66
@onready var prism_anim = $Head/Camera3D/Hand/GunPrism/AnimationPlayer
@onready var prism_barrel = $Head/Camera3D/Hand/GunPrism/Barrel
@onready var prism_flash = $Head/Camera3D/Hand/GunPrism/MuzzleFlash
@onready var p_ray1 = $Head/Camera3D/PrismRays/PRay1
@onready var p_ray2 = $Head/Camera3D/PrismRays/PRay2
@onready var p_ray3 =$Head/Camera3D/PrismRays/PRay3
@onready var p_ray4 =$Head/Camera3D/PrismRays/PRay4
@onready var p_ray5 =$Head/Camera3D/PrismRays/PRay5
@onready var p_ray6 =$Head/Camera3D/PrismRays/PRay6
@onready var p_ray7 =$Head/Camera3D/PrismRays/PRay7
@onready var p_ray8 =$Head/Camera3D/PrismRays/PRay8
@onready var p_ray9 =$Head/Camera3D/PrismRays/PRay9
@onready var p_ray10 =$Head/Camera3D/PrismRays/PRay10
@onready var p_ray11 =$Head/Camera3D/PrismRays/PRay11
@onready var p_ray12 =$Head/Camera3D/PrismRays/PRay12
@onready var p_ray13 =$Head/Camera3D/PrismRays/PRay13
@onready var p_ray14 =$Head/Camera3D/PrismRays/PRay14
@onready var p_ray15 =$Head/Camera3D/PrismRays/PRay15


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	elif isCrouch == false:
		speed = WALK_SPEED
	
	# Crouch
	if Input.is_action_just_pressed("crouch") and isCrouch == false:
		scale /= 2
		isCrouch = true
	elif Input.is_action_just_pressed("crouch")and isCrouch == true:
		scale *= 2
		speed = WALK_SPEED
		camera.rotation = camera.rotation.lerp(Vector3.ZERO, 1.0)
		isCrouch = false
	
	if isCrouch == true and not is_on_floor():
		speed = WALK_SPEED * 2
		speed *= 1.05
		
		if Input.is_action_pressed("right"):
			camera.rotate(Vector3.FORWARD,speed * 0.0005)
		if Input.is_action_pressed("left"):
			camera.rotate(-Vector3.FORWARD,speed * 0.0005)
		if Input.is_action_pressed("up"):
			camera.rotate(-Vector3.RIGHT,speed * 0.0005)
		if Input.is_action_pressed("down"):
			camera.rotate(Vector3.RIGHT,speed * 0.0005)
		
	elif isCrouch == true and is_on_floor():
		speed = WALK_SPEED/2
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()
	
	# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			weapons.BALL:
				if gun_ammo > 0:
					shoot_gun_ball()
			weapons.PRISM:
				if prism_ammo > 0:
					shoot_prism()
	
		# Weapon Switching
	if Input.is_action_just_pressed("weapon1") and weapon != weapons.BALL and !prism_anim.is_playing() and weapon_availability[weapons.BALL] == true:
		bullets_in_chamber = 0
		emit_signal("show_ammo",gun_ammo)
		_raise_weapon(weapons.BALL)
	if Input.is_action_just_pressed("weapon2") and weapon != weapons.PRISM and !gun_anim.is_playing() and weapon_availability[weapons.PRISM] == true:
		emit_signal("show_ammo",prism_ammo)
		_raise_weapon(weapons.PRISM)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func hit(dir, damage):
	if damage < 0:
		audio.play()
		emit_signal("player_hit", damage)
	else:
		emit_signal("player_hit", damage)
		velocity += dir * 8.0

func flash(f):
	f.show()
	await get_tree().create_timer(0.1).timeout
	f.hide()

func shoot_gun_ball():
	if(!gun_anim.is_playing()):
		if (bullets_in_chamber < 6):
			bullets_in_chamber += 1
			gun_anim.speed_scale = 0.8
			gun_anim.play("Shoot")
			gun_ammo = gun_ammo - 1
			emit_signal("show_ammo",gun_ammo)
			flash(gun_flash)
			if main_ray.is_colliding():
				for i in range(1):
					var instance = bullet_trail.instantiate()
					get_parent().add_child(instance)
					instance.init(gun_barrel.global_position, main_ray.get_collision_point())
					if main_ray.get_collider().is_in_group("enemy"):
						main_ray.get_collider().hit(1)
						instance.trigger_particles(main_ray.get_collision_point(), gun_barrel.global_position, true)
					else:
						instance.trigger_particles(main_ray.get_collision_point(), gun_barrel.global_position, false)
					shaker.play_shake()
		else:
			gun_anim.speed_scale = 1
			gun_anim.play("Reload")
			bullets_in_chamber = 0

func shoot_prism():
	if !prism_anim.is_playing():
		prism_anim.speed_scale = 0.8
		prism_anim.play("Shoot")
		prism_ammo = prism_ammo - 1
		emit_signal("show_ammo",prism_ammo)
		# Tablica z raycastami
		var rays = [p_ray1, p_ray2, p_ray3, p_ray4, p_ray5, p_ray6, p_ray7, p_ray8, p_ray9, p_ray10, p_ray11, p_ray12, p_ray13, p_ray14, p_ray15]
		
		# Pętla po wszystkich raycastach
		for ray in rays:
			if ray.is_colliding():
				var instance = bullet_trail.instantiate()
				get_parent().add_child(instance)
				instance.init(prism_barrel.global_position, ray.get_collision_point())
				if ray.get_collider().is_in_group("enemy"):
					ray.get_collider().hit(0.65)
					instance.trigger_particles(ray.get_collision_point(), prism_barrel.global_position, true)
				else:
					instance.trigger_particles(ray.get_collision_point(), prism_barrel.global_position, false)
			else:
				pass
				#napraw to później
				#instance.init(prism_barrel.global_position, ray_end.global_position)
				#get_parent().add_child(instance)

func _lower_weapon():
	match weapon:
		weapons.BALL:
			weapon_switching.play("LowerBall")
		weapons.PRISM:
			weapon_switching.play("LowerPrism")


func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await get_tree().create_timer(0.3).timeout
	match new_weapon:
		weapons.BALL:
			weapon_switching.play_backwards("LowerBall")
		weapons.PRISM:
			weapon_switching.play_backwards("LowerPrism")
	weapon = new_weapon
	can_shoot = true

# jest problem że jak trzymasz np pistolet a podniesiesz ammo shotguna to zacznie ci wyswietlac ammo shotunge
func collect_ammo(type,amount):
	if type == "P":
		audio.play()
		prism_ammo = prism_ammo + amount
		emit_signal("show_ammo",prism_ammo)
	if type == "G":
		audio.play()
		gun_ammo = gun_ammo + amount
		emit_signal("show_ammo",gun_ammo)

func collect_weapon(weapon: int, is_available: bool) -> void:
	if weapon in weapons.values():
		weapon_availability[weapon] = is_available
		print("Broń ", weapons.keys()[weapon], " jest teraz ", "dostępna" if is_available else "niedostępna")
	else:
		print("Nieprawidłowy indeks broni!")
