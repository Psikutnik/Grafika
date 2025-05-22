extends Area3D

@export var nextlevel = "res://world.tscn"
@export var level_number = 1
@onready var finnish_menu: Control = $FinnishMenu
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var lev_time: float = 0
var time: float = 0
var minutes: int = 0
var seconds: int = 0
var mseconds: int = 0
@onready var czas: Label = $FinnishMenu/Czas
@onready var best: Label = $FinnishMenu/Best
@onready var zabojstwa: Label = $FinnishMenu/Zabojstwa
@onready var sekrety: Label = $FinnishMenu/Sekrety


func _ready() -> void: 
	if level_number == 1:
		FileSave.lev1_enemies = 0
		FileSave.lev1_kills = 0
		FileSave.lev1_secret = 0
		FileSave.lev1_secret_found = 0
		lev_time = FileSave.lev1_time
	if level_number == 2:
		FileSave.lev2_enemies = 0
		FileSave.lev2_kills = 0
		lev_time = FileSave.lev2_time
		FileSave.lev2_secret = 0
		FileSave.lev2_secret_found = 0


func _process(delta: float) -> void:
	time += delta

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		#timer
		mseconds = fmod(time, 1) * 10
		seconds = fmod(time, 60)
		minutes = fmod(time, 3600)
		czas.text = "CZAS " + str(minutes) + "," + str(seconds) + str(mseconds)
		if time < lev_time:
			best.text = "Best " + str(minutes) + "," + str(seconds) + str(mseconds)
			lev_time = time
			FileSave.changeBest(level_number, lev_time)
		else:
			mseconds = fmod(lev_time, 1) * 10
			seconds = fmod(lev_time, 60)
			minutes = fmod(lev_time, 3600)
			best.text = "Best " + str(minutes) + "," + str(seconds) + str(mseconds)
		
		#Kills and Secrets
		if level_number == 1:
			zabojstwa.text = "Zabojstwa " + str(FileSave.lev1_kills) +  " na " + str(FileSave.lev1_enemies) 
			sekrety.text = "Sekrety " + str(FileSave.lev1_secret_found) + " na " + str(FileSave.lev1_secret)
		if level_number == 2:
			zabojstwa.text = "Zabojstwa " + str(FileSave.lev2_kills) +  " na " + str(FileSave.lev2_enemies) 
			sekrety.text = "Sekrety " + str(FileSave.lev2_secret_found) + " na " + str(FileSave.lev2_secret)
		#Menu
		audio.play()
		finnish_menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true


func _on_next_level_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(nextlevel)


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://world.tscn")


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
