# handles swimming/drifting logic for bowl items (sponges, algae, fish eggs)
extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO

@export var main_menu_mode := false
@export var min_spacing := 10000.0
@export var max_speed := 300.0

var dragging := false
var drag_offset := Vector2.ZERO

const ITEM_GROUP := "bowl_items"

func _ready():
	if scene_file_path.ends_with("sponge.tscn"):
		scale = Vector2(0.04, 0.04)
	elif scene_file_path.ends_with("algae.tscn"):
		scale = Vector2(0.02, 0.02)
	elif scene_file_path.ends_with("fisheggs.tscn"):
		scale = Vector2(0.04, 0.04)

	add_to_group(ITEM_GROUP)
	rotation = randf_range(0.0, TAU)

# Call this from the spawner AFTER setting radius_x, radius_y, bowl_center
func setup(center: Vector2, rx: float, ry: float) -> void:
	bowl_center = center
	radius_x = rx
	radius_y = ry
	global_position = _find_spawn_point()

func _find_spawn_point() -> Vector2:
	var pos := bowl_center
	var tries := 0
	while tries < 30:
		var angle := randf() * TAU
		var r := sqrt(randf())
		pos = bowl_center + Vector2(cos(angle) * radius_x * r, sin(angle) * radius_y * r)
		var ok := true
		for other in get_tree().get_nodes_in_group(ITEM_GROUP):
			if other == self:
				continue
			if pos.distance_to(other.global_position) < min_spacing:
				ok = false
				break
		if ok:
			return pos
		tries += 1
	return pos
