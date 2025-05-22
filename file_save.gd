extends Node

#OPTIONS
var volume: float = 30.0
var resolution: int = 0
var fullscreen: bool = false

#STATS
var lev1_time: float = 9999999999
var lev1_enemies: int = 0
var lev1_kills: int = 0
var lev1_secret: int = 0
var lev1_secret_found: int = 0
var lev2_time: float = 9999999999
var lev2_enemies: int = 0
var lev2_kills: int = 0
var lev2_secret: int = 0
var lev2_secret_found: int = 0

func changeBest(n, czas):
	if n == 1:
		lev1_time = czas
	if n == 2:
		lev2_time = czas

func enemy_update(n):
	if n == 1:
		lev1_enemies += 1
	if n == 2:
		lev2_enemies += 1

func kill_update(n):
	if n == 1:
		lev1_kills += 1
	if n == 2:
		lev2_kills += 1

func secret_update(n):
	if n == 1:
		lev1_secret += 1
	if n == 2:
		lev2_secret += 1

func secret_found_update(n):
	if n == 1:
		lev1_secret_found += 1
	if n == 2:
		lev2_secret_found += 1
