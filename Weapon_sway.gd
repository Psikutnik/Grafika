extends Node3D

var mouse_mov := Vector2.ZERO
var sway_treshold := 5.0
var sway_lerp := 5.0
@export var left : float
var sway_left : Vector3
@export var right : float
var sway_right : Vector3
@export var up : float
var sway_up : Vector3
@export var down : float
var sway_down : Vector3
@export var sway_normal : Vector3

func _ready() -> void:
	sway_left = Vector3.DOWN * left
	sway_right = Vector3.UP * right
	sway_up = Vector3.RIGHT * up
	sway_down = Vector3.LEFT * down

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_mov = event.relative

func _process(delta: float) -> void:
	var target_rotation := sway_normal
	
	if mouse_mov.length() > sway_treshold:
		if mouse_mov.x > sway_treshold:
			target_rotation += sway_left
		elif mouse_mov.x < -sway_treshold:
			target_rotation += sway_right
		
		if mouse_mov.y > sway_treshold:
			target_rotation += sway_down
		elif mouse_mov.y < -sway_treshold:
			target_rotation += sway_up
	
	rotation = rotation.lerp(target_rotation, sway_lerp * delta)
	mouse_mov = Vector2.ZERO * 0.9  # Damping
