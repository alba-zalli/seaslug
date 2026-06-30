extends Node2D

var scaler = DisplayServer.screen_get_size().y / 175
var radius_x = 90 * scaler
var radius_y = 60 * scaler

@onready var bowl = $BowlLogic
@onready var container = $SlugContainer

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

var sapsucker_scene = preload("res://sapsucker.tscn")
var caldorid_scene = preload("res://caldorid.tscn")
var hyps_scene = preload("res://hyps.tscn")
var phyl_scene = preload("res://phyl.tscn")
var mari_scene = preload("res://mari.tscn")
var flab_scene = preload("res://flab.tscn")
var gonio_scene = preload("res://gonio.tscn")
var paradisa_scene = preload("res://paradisa.tscn")

func fish_maker(fish):
	fish.radius_x = radius_x
	fish.radius_y = radius_y
	fish.bowl_center = DisplayServer.screen_get_size() / 2
	add_child(fish)
	fish.global_position = fish.bowl_center
	fish.main_menu_mode = false
	
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
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var num_points = 64
	var center = DisplayServer.screen_get_size() / 2
	
	if is_main_menu():
		for i in range(5):
			var random_spawn = spawn_functions[randi() % spawn_functions.size()]
			random_spawn.call()
	else:
		for i in range(num_points):
			var angle = (2.0 * PI * i) / num_points
			points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
			polygon.polygon = points
			polygon.position = center
			add_child(polygon)


func _on_sapsucker_button_down() -> void:
	spawn_sapsucker()

func _on_cal_dorid_button_down() -> void:
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
