extends Node2D
# SPAWNS FISH IN INTRO SCREEN
var scaler = DisplayServer.screen_get_size().y / 175
var radius_x = 90 * scaler
var radius_y = 60 * scaler

@onready var book = get_tree().get_first_node_in_group("book")

var spawn_functions := [
	Callable(self, "spawn_sapsucker"),
	Callable(self, "spawn_caldorid"),
	Callable(self, "spawn_hyps"),
	Callable(self, "spawn_phyl"),
	Callable(self, "spawn_mari"),
	Callable(self, "spawn_flab"),
	Callable(self, "spawn_gonio"),
	Callable(self, "spawn_paradisa"),
	Callable(self, "spawn_sponge"),
	Callable(self, "spawn_algae"),
	Callable(self, "spawn_fish")
]

#load fish scenes
var sapsucker_scene = preload("res://assetscenes/slugscenes/sapsucker.tscn")
var caldorid_scene = preload("res://assetscenes/slugscenes/caldorid.tscn")
var hyps_scene = preload("res://assetscenes/slugscenes/hyps.tscn")
var phyl_scene = preload("res://assetscenes/slugscenes/phyl.tscn")
var mari_scene = preload("res://assetscenes/slugscenes/mari.tscn")
var flab_scene = preload("res://assetscenes/slugscenes/flab.tscn")
var gonio_scene = preload("res://assetscenes/slugscenes/gonio.tscn")
var paradisa_scene = preload("res://assetscenes/slugscenes/paradisa.tscn")
var sponge_scene = preload("res://assetscenes/foodscenes/sponge.tscn")
var alg_scene = preload("res://assetscenes/foodscenes/algae.tscn")
var fish_scene = preload("res://assetscenes/foodscenes/fisheggs.tscn")

#load data resources
var sapsucker_data: SlugData = preload("res://data/sapsucker_data.tres")
var caldorid_data: SlugData = preload("res://data/caldorid_data.tres")
var hyps_data: SlugData = preload("res://data/caldorid_data.tres")
var phyl_data: SlugData = preload("res://data/caldorid_data.tres")
var mari_data: SlugData = preload("res://data/caldorid_data.tres")
var flab_data: SlugData = preload("res://data/caldorid_data.tres")
var gonio_data: SlugData = preload("res://data/caldorid_data.tres")
var paradisa_data: SlugData = preload("res://data/caldorid_data.tres")
var sponge_data: SlugData = preload("res://data/caldorid_data.tres")
var algae_data: SlugData = preload("res://data/caldorid_data.tres")
var fish_data: SlugData = preload("res://data/caldorid_data.tres")

# helper function
func fish_maker(fish, data: SlugData = null):
	print("FISH_MAKER CALLED with ", fish)
	fish.radius_x = radius_x
	fish.radius_y = radius_y
	fish.main_menu_mode = false
	add_child(fish)
	if data != null:
		var book_node = get_tree().get_first_node_in_group("book")
		if book_node:
			book_node.open_book_to(data)

func food_maker(food):
	print("FISH_MAKER CALLED with ", food)
	food.radius_x = radius_x
	food.radius_y = radius_y
	add_child(food)
	food.setup(food.bowl_center, radius_x, radius_y)

func spawn_sponge():
	var sponge = sponge_scene.instantiate()
	food_maker(sponge)

func spawn_algae():
	var algea = alg_scene.instantiate()
	food_maker(algea)

func spawn_fish():
	var fish = fish_scene.instantiate()
	food_maker(fish)
	
func spawn_gonio():
	var fish = gonio_scene.instantiate()
	fish_maker(fish, gonio_data)
	
func spawn_flab():
	var fish = flab_scene.instantiate()
	fish_maker(fish, flab_data)

func spawn_mari():
	var fish = mari_scene.instantiate()
	fish_maker(fish, mari_data)

func spawn_sapsucker():
	var fish = sapsucker_scene.instantiate()
	fish_maker(fish, sapsucker_data)
	
func spawn_caldorid():
	var fish = caldorid_scene.instantiate()
	fish_maker(fish , caldorid_data)
	
func spawn_hyps():
	var fish = hyps_scene.instantiate()
	fish_maker(fish, hyps_data)
	
func spawn_phyl():
	var fish = phyl_scene.instantiate()
	fish_maker(fish, phyl_data)

func spawn_paradisa():
	var fish = paradisa_scene.instantiate()
	fish_maker(fish, paradisa_data)
	
func _ready():
	print("SPAWNER READY on scene: ", get_tree().current_scene.scene_file_path)
	randomize()
	
	if is_main_menu():
		for i in range(5):
			var random_spawn = spawn_functions[randi() % spawn_functions.size()]
			random_spawn.call()

func _on_sapsucker_button_down() -> void:
	spawn_sapsucker()

func _on_cal_dorid_button_down() -> void:
	print("CALDORID BUTTON PRESSED")
	spawn_caldorid()

func _on_hypselodoris_button_down() -> void:
	spawn_hyps()

func _on_phyllidiella_button_down() -> void:
	spawn_phyl()

func _on_flabellina_button_down() -> void:
	spawn_flab()

func _on_marindica_button_down() -> void:
	spawn_mari()

func _on_gonio_button_down() -> void:
	spawn_gonio()

func _on_paradisa_button_down() -> void:
	spawn_paradisa()

# is main menu 
func is_main_menu() -> bool:
	return get_tree().current_scene.scene_file_path.ends_with("main_menu.tscn")

func _on_sea_sponge_button_down() -> void:
	spawn_sponge()

func _on_algae_button_down() -> void:
	spawn_algae()

func _on_fish_eggs_button_down() -> void:
	spawn_fish()

func _on_glass_toggled(toggled_on: bool) -> void:
	get_tree().call_group("magglass", "toggle_visible", toggled_on)
