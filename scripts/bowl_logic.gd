extends Node2D

# HANDLES FOOD AND SLUG SPAWNING


func _get_scaler() -> float:
	return get_viewport_rect().size.y / 175.


func _get_bowl_center() -> Vector2:
	return get_viewport_rect().size / 2.


func _get_radius_x() -> float:
	return 90. * _get_scaler()


func _get_radius_y() -> float:
	return 60. * _get_scaler()

# ===================================
# LIMITS
# ===================================

const MAX_FOOD_ITEMS := 4
const MAX_SLUG_ITEMS := 9



@onready var book = get_tree().get_first_node_in_group("book")



# ===================================
# DATA
# ===================================

var caldorid_data: SlugData = preload("res://data/caldorid_data.tres")
var sapsucker_data: SlugData = preload("res://data/sapsucker_data.tres")
var hyps_data: SlugData = preload("res://data/hyps_data.tres")
var phyl_data: SlugData = preload("res://data/phyl_data.tres")
var flab_data: SlugData = preload("res://data/flab_data.tres")
var mari_data: SlugData = preload("res://data/mari_data.tres")
var paradisa_data: SlugData = preload("res://data/paradisa_data.tres")
var gonio_data: SlugData = preload("res://data/gonio_data.tres")



# ===================================
# RANDOM SPAWN LIST
# ===================================

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



# ===================================
# SCENES
# ===================================

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



# ===================================
# LIMIT CHECKS
# ===================================

func can_spawn_food() -> bool:

	var current_food := get_tree().get_nodes_in_group("food").size()

	print("FOOD COUNT: ", current_food, "/", MAX_FOOD_ITEMS)

	return current_food < MAX_FOOD_ITEMS



func can_spawn_slug() -> bool:

	var current_slugs := get_tree().get_nodes_in_group("slug").size()

	print("SLUG COUNT: ", current_slugs, "/", MAX_SLUG_ITEMS)

	return current_slugs < MAX_SLUG_ITEMS





# ===================================
# SPAWN HELPERS
# ===================================

func food_maker(food):

	if not can_spawn_food():

		print("MAX FOOD REACHED")

		food.queue_free()

		return


	food.radius_x = _get_radius_x()
	food.radius_y = _get_radius_y()
	food.bowl_center = _get_bowl_center()


	food.add_to_group("food")


	add_child(food)


	food.global_position = _random_bowl_position()



func fish_maker(fish, data: SlugData = null):

	if not can_spawn_slug():

		print("MAX SLUGS REACHED")

		fish.queue_free()

		return


	fish.radius_x = _get_radius_x()
	fish.radius_y = _get_radius_y()
	fish.bowl_center = _get_bowl_center()

	fish.slug_data = data


	fish.add_to_group("slug")


	add_child(fish)


	fish.global_position = _random_bowl_position()


	fish.main_menu_mode = false



	if data != null:

		var book_node = get_tree().get_first_node_in_group("book")

		if book_node:

			book_node.open_book_to(data)





# ===================================
# CLEAR BOWL
# ===================================

func clear_bowl():
	print("CLEARING BOWL")
	var food_items = get_tree().get_nodes_in_group("food")
	for food in food_items:
		food.queue_free()
	var slugs = get_tree().get_nodes_in_group("slug")
	for slug in slugs:
		slug.queue_free()
	print("BOWL CLEARED")





# ===================================
# RANDOM POSITION
# ===================================

func _random_bowl_position() -> Vector2:

	var center = _get_bowl_center()

	var rx = _get_radius_x()

	var ry = _get_radius_y()


	var angle = randf() * TAU

	var dist = sqrt(randf())


	var offset = Vector2(
		cos(angle) * rx,
		sin(angle) * ry
	) * dist * 0.85


	return center + offset





# ===================================
# FOOD SPAWN
# ===================================

func spawn_sponge():

	food_maker(sponge_scene.instantiate())



func spawn_algae():

	food_maker(alg_scene.instantiate())



func spawn_fish():

	food_maker(fish_scene.instantiate())





# ===================================
# SLUG SPAWN
# ===================================

func spawn_gonio():
	fish_maker(gonio_scene.instantiate(), gonio_data)


func spawn_flab():
	fish_maker(flab_scene.instantiate(), flab_data)


func spawn_mari():
	fish_maker(mari_scene.instantiate(), mari_data)


func spawn_sapsucker():
	fish_maker(sapsucker_scene.instantiate(), sapsucker_data)


func spawn_caldorid():
	fish_maker(caldorid_scene.instantiate(), caldorid_data)


func spawn_hyps():
	fish_maker(hyps_scene.instantiate(), hyps_data)


func spawn_phyl():
	fish_maker(phyl_scene.instantiate(), phyl_data)


func spawn_paradisa():
	fish_maker(paradisa_scene.instantiate(), paradisa_data)





# ===================================
# READY
# ===================================

func _ready():

	print("BOWL SPAWNER")

	randomize()


	if is_main_menu():

		for i in range(5):

			var random_spawn = spawn_functions[randi() % spawn_functions.size()]

			random_spawn.call()





# ===================================
# BUTTONS
# ===================================

func _on_sapsucker_button_down():
	spawn_sapsucker()


func _on_cal_dorid_button_down():

	print("CALDORID BUTTON PRESSED")

	spawn_caldorid()



func _on_hypselodoris_button_down():
	spawn_hyps()



func _on_phyllidiella_button_down():
	spawn_phyl()



func _on_flabellina_button_down():
	spawn_flab()



func _on_marindica_button_down():
	spawn_mari()



func _on_gonio_button_down():
	spawn_gonio()



func _on_paradisa_button_down():
	spawn_paradisa()

func is_main_menu() -> bool:
	return get_tree().current_scene.scene_file_path.ends_with("main_menu.tscn")

func _on_sea_sponge_button_down():
	spawn_sponge()



func _on_algae_button_down():
	spawn_algae()



func _on_fish_eggs_button_down():

	spawn_fish()



func _on_glass_toggled(toggled_on: bool):

	get_tree().call_group("magglass", "toggle_visible", toggled_on)



func _on_clear_bowl_button_down() -> void:

	clear_bowl()


func _on_clear_bowl_pressed() -> void:
	pass # Replace with function body.


func _on_tutorial_button_down() -> void:
	DialogueManager.show_dialogue_balloon(
		load("res://dialogue/tutorial.dialogue"),
		"start"
	)
