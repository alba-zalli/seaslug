# handles swimming/drifting logic for bowl items (sponges, algae, fish eggs)
extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO

@export var main_menu_mode := false
@export var min_spacing := 1.0
@export var max_speed := 300.0

var dragging := false
var drag_offset := Vector2.ZERO

const ITEM_GROUP := "bowl_items"

func _ready():
	print("what")
	if scene_file_path.ends_with("sponge.tscn"):
		scale = Vector2(0.04, 0.04)
	elif scene_file_path.ends_with("algae.tscn"):
		scale = Vector2(0.02, 0.02)
	elif scene_file_path.ends_with("fisheggs.tscn"):
		scale = Vector2(0.04, 0.04)

	add_to_group(ITEM_GROUP)
	rotation = randf_range(0.0, TAU)
