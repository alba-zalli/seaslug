extends Node2D

func _get_scaler() -> float:
	return get_viewport_rect().size.y / 175.

func _get_bowl_center() -> Vector2:
	return get_viewport_rect().size / 2.

func _get_radius_x() -> float:
	return 90. * _get_scaler()

func _get_radius_y() -> float:
	return 60. * _get_scaler()
	
var radius_x = 90. * _get_scaler()
var radius_y = 60. * _get_scaler()

@onready var book = get_tree().get_first_node_in_group("book")

var caldorid_data: SlugData = preload("res://data/caldorid_data.tres")
var sapsucker_data: SlugData = preload("res://data/sapsucker_data.tres")
var hyps_data: SlugData = preload("res://data/hyps_data.tres")
var phyl_data: SlugData = preload("res://data/phyl_data.tres")
var flab_data: SlugData = preload("res://data/flab_data.tres")
var mari_data: SlugData = preload("res://data/mari_data.tres")
var paradisa_data: SlugData = preload("res://data/paradisa_data.tres")
var gonio_data: SlugData = preload("res://data/gonio_data.tres")

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

func spawn_sponge():
	var sponge = sponge_scene.instantiate()
	food_maker(sponge)

func spawn_algae():
	var algea = alg_scene.instantiate()
	food_maker(algea)

func spawn_fish():
	var fish = fish_scene.instantiate()
	food_maker(fish)

# function overloading for fish maker
func food_maker(fish):
	fish.radius_x = _get_radius_x()
	fish.radius_y = _get_radius_y()
	fish.bowl_center = _get_bowl_center()
	add_child(fish)
	fish.global_position = _random_bowl_position()

func fish_maker(fish, data: SlugData = null):
	fish.radius_x = _get_radius_x()
	fish.radius_y = _get_radius_y()
	fish.bowl_center = _get_bowl_center()
	fish.slug_data = data
	add_child(fish)
	fish.global_position = _random_bowl_position()
	fish.main_menu_mode = false
	if data != null:
		book.open_book_to(data)

func _random_bowl_position() -> Vector2:
	var center = _get_bowl_center()
	var rx = _get_radius_x()
	var ry = _get_radius_y()
	var angle = randf() * TAU
	var dist = sqrt(randf())
	var offset = Vector2(cos(angle) * rx, sin(angle) * ry) * dist * 0.85
	return center + offset
	
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
	fish_maker(fish, caldorid_data)
	
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
	print("BOWL SPAWNER")
	randomize()
	
	if is_main_menu():
		for i in range(5):
			var random_spawn = spawn_functions[randi() % spawn_functions.size()]
			random_spawn.call()

func _on_sapsucker_button_down() -> void:
	spawn_sapsucker()

func _on_cal_dorid_button_down() -> void:
	print("CALDORID BUTTON PRESSED on scene: ", get_tree().current_scene.scene_file_path)
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
