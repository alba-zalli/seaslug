extends Node2D

var radius_x = DisplayServer.screen_get_size().x / 2 
var radius_y = DisplayServer.screen_get_size().y /2 
var size = 2.3

var spawn_functions := [
	Callable(self, "spawn_sapsucker"),
	Callable(self, "spawn_caldorid"),
	Callable(self, "spawn_hyps"),
	Callable(self, "spawn_phyl"),
	Callable(self, "spawn_mari"),
	Callable(self, "spawn_flab"),
	Callable(self, "spawn_gonio"),
	Callable(self, "spawn_paradisa")
]

var sapsucker_scene = preload("res://assetscenes/slugscenes/sapsucker.tscn")
var caldorid_scene = preload("res://assetscenes/slugscenes/caldorid.tscn")
var hyps_scene = preload("res://assetscenes/slugscenes/hyps.tscn")
var phyl_scene = preload("res://assetscenes/slugscenes/phyl.tscn")
var mari_scene = preload("res://assetscenes/slugscenes/mari.tscn")
var flab_scene = preload("res://assetscenes/slugscenes/flab.tscn")
var gonio_scene = preload("res://assetscenes/slugscenes/gonio.tscn")
var paradisa_scene = preload("res://assetscenes/slugscenes/paradisa.tscn")

func fish_maker(fish):
	print("Spawning: ", fish.scene_file_path)
	fish.radius_x = radius_x
	fish.radius_y = radius_y
	fish.bowl_center = DisplayServer.screen_get_size() / 2
	fish.size = size
	
	add_child(fish)

	var center = fish.bowl_center
	
	var random_offset = Vector2(
		randf_range(-radius_x, radius_x),
		randf_range(-radius_y, radius_y)
	)
	
	fish.global_position = center + random_offset
	fish.main_menu_mode = true
	
func spawn_gonio():
	var fish = gonio_scene.instantiate()
	fish_maker(fish)
	
func spawn_flab():
	var fish = flab_scene.instantiate()
	fish_maker(fish)

func spawn_mari():
	var fish = mari_scene.instantiate()
	fish_maker(fish)

func spawn_sapsucker():
	var fish = sapsucker_scene.instantiate()
	fish_maker(fish)
	
func spawn_caldorid():
	var fish = caldorid_scene.instantiate()
	fish_maker(fish)
	
func spawn_hyps():
	var fish = hyps_scene.instantiate()
	fish_maker(fish)
	
func spawn_phyl():
	var fish = phyl_scene.instantiate()
	fish_maker(fish)

func spawn_paradisa():
	var fish = paradisa_scene.instantiate()
	fish_maker(fish)
	
func _ready():
	randomize()
	
	for i in range(7):
		var random_spawn = spawn_functions[randi() % spawn_functions.size()]
		random_spawn.call()

# is main menu 
func is_main_menu() -> bool:
	return get_tree().current_scene.scene_file_path.ends_with("main_menu.tscn")
