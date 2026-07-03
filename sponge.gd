extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO
@export var main_menu_mode := false
@export var min_spacing := 40.0     # minimum distance between sponge spawn points
@export var max_speed := 300.0      # cap on collision-push velocity

var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	if scene_file_path.ends_with("sponge.tscn"):
		scale = Vector2(0.04, 0.04)
	elif scene_file_path.ends_with("algae.tscn"):
		scale = Vector2(0.02, 0.02)
	elif scene_file_path.ends_with("fisheggs.tscn"):
		scale = Vector2(0.04, 0.04)

	add_to_group("sponges")

	if radius_x > 0.0 and radius_y > 0.0:
		global_position = _find_spawn_point()

	rotation = randf_range(0.0, TAU)  # random starting rotation


func _find_spawn_point() -> Vector2:
	var pos := bowl_center
	var tries := 0
	while tries < 30:
		var angle := randf() * TAU
		var r := sqrt(randf())
		pos = bowl_center + Vector2(cos(angle) * radius_x * r, sin(angle) * radius_y * r)

		var ok := true
		for other in get_tree().get_nodes_in_group("sponges"):
			if other == self:
				continue
			if pos.distance_to(other.global_position) < min_spacing:
				ok = false
				break

		if ok:
			return pos
		tries += 1

	return pos  # fall back to last attempt if we couldn't find a clean spot


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_mouse_over_sponge():
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
				z_index = 10
		else:
			if dragging:
				dragging = false
				z_index = 0

	elif event is InputEventMouseMotion and dragging:
		var target := get_global_mouse_position() + drag_offset
		global_position = _clamp_to_bowl(target)


func _is_mouse_over_sponge() -> bool:
	var space_state := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_bodies = true
	params.collide_with_areas = false
	var result := space_state.intersect_point(params, 32)
	for hit in result:
		if hit.collider == self:
			return true
	return false


func _clamp_to_bowl(pos: Vector2) -> Vector2:
	if radius_x <= 0.0 or radius_y <= 0.0:
		return pos

	var local := pos - bowl_center
	var norm_dist := (local.x * local.x) / (radius_x * radius_x) \
			+ (local.y * local.y) / (radius_y * radius_y)

	if norm_dist > 1.0:
		var scale_factor := 1.0 / sqrt(norm_dist)
		local *= scale_factor
		return bowl_center + local

	return pos


func _physics_process(_delta: float) -> void:
	if dragging:
		velocity = Vector2.ZERO
		return

	move_and_slide()

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	global_position = _clamp_to_bowl(global_position)
