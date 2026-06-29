extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO
var dragging := false
var drag_offset := Vector2.ZERO
var swim_direction := Vector2.RIGHT
var swim_speed := 60.0
var orbit_angle := 0.0
var orbit_wobble := 0.0
var wobble_timer := 0.0

@onready var swim_animation = $AnimationPlayer

func _ready():
	if scene_file_path.ends_with("caldorid.tscn"):
		scale = Vector2(0.04, 0.04)
	elif scene_file_path.ends_with("sapsucker.tscn"):
		scale = Vector2(0.02, 0.02)
	elif scene_file_path.ends_with("hyps.tscn"):
		scale = Vector2(0.2, 0.2)
	elif scene_file_path.ends_with("phyl.tscn"):
		scale = Vector2(0.07, 0.07)
	elif scene_file_path.ends_with("mari.tscn"):
		scale = Vector2(0.07, 0.07)
	elif scene_file_path.ends_with("flab.tscn"):
		scale = Vector2(0.07, 0.07)
	elif scene_file_path.ends_with("gonio.tscn"):
		scale = Vector2(0.07, 0.07)
	elif scene_file_path.ends_with("paradisa.tscn"):
		scale = Vector2(0.07, 0.07)

	# each fish starts at a random point around the orbit
	orbit_angle = randf() * TAU
	wobble_timer = randf_range(0.0, 3.0)
	swim_animation.play("swim_animation")

func _is_clicking_on_fish(mouse_pos: Vector2) -> bool:
	for child in get_children():
		if child is Polygon2D:
			var local_mouse = child.get_global_transform().affine_inverse() * mouse_pos
			if Geometry2D.is_point_in_polygon(local_mouse, child.polygon):
				return true
	return false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_clicking_on_fish(event.position):
				dragging = true
				drag_offset = global_position - event.position
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = event.position + drag_offset

func _physics_process(delta):
	if dragging:
		velocity = Vector2.ZERO
		return

	var screen_size = get_viewport_rect().size
	var margin = 40.0

	# Turn away from screen edges
	if global_position.x < margin:
		swim_direction = Vector2.RIGHT.rotated(randf_range(-0.5, 0.5))
	elif global_position.x > screen_size.x - margin:
		swim_direction = Vector2.LEFT.rotated(randf_range(-0.5, 0.5))

	if global_position.y < margin:
		swim_direction = Vector2.DOWN.rotated(randf_range(-0.5, 0.5))
	elif global_position.y > screen_size.y - margin:
		swim_direction = Vector2.UP.rotated(randf_range(-0.5, 0.5))

	# Occasionally wander a little
	if randf() < delta * 0.4:
		swim_direction = swim_direction.rotated(randf_range(-0.4, 0.4)).normalized()

	velocity = swim_direction * swim_speed
	move_and_slide()

	# Keep fish fully inside the screen
	global_position.x = clamp(global_position.x, margin, screen_size.x - margin)
	global_position.y = clamp(global_position.y, margin, screen_size.y - margin)

	# Face the direction of travel
	var target_angle = swim_direction.angle() + PI / 2
	rotation = lerp_angle(rotation, target_angle, 0.08)
