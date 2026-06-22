extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO

var dragging := false
var drag_offset := Vector2.ZERO

var swim_direction := Vector2.RIGHT
var swim_speed := 60.0

var turn_timer := 0.0

# ───────── NEW: AVOIDANCE ─────────
var avoid_radius := 100.0
var avoid_strength := 2.5

@onready var swim_animation = $AnimationPlayer


func _ready():
	if scene_file_path.ends_with("caldorid.tscn"):
		scale = Vector2(0.035, 0.035)
	elif scene_file_path.ends_with("sapsucker.tscn"):
		scale = Vector2(0.02, 0.02)

	swim_direction = Vector2.RIGHT.rotated(randf() * TAU)
	turn_timer = randf_range(2.0, 5.0)

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

	# ───────── SMOOTH RANDOM WANDER ─────────
	turn_timer -= delta
	if turn_timer <= 0.0:
		swim_direction = swim_direction.rotated(randf_range(-0.2, 0.2)).normalized()
		turn_timer = randf_range(2.0, 5.0)

	# ───────── SMOOTH FISH AVOIDANCE (KEY FIX) ─────────
	var steer := Vector2.ZERO

	for fish in get_parent().get_children():
		if fish == self:
			continue
		if not fish is CharacterBody2D:
			continue

		var diff = global_position - fish.global_position
		var dist = diff.length()

		if dist > 0 and dist < avoid_radius:
			var t = 1.0 - (dist / avoid_radius)
			steer += diff.normalized() * t

	if steer.length() > 0:
		swim_direction = (swim_direction + steer * avoid_strength).normalized()

	# ───────── BOWL EDGE BEHAVIOR ─────────
	var rel = global_position - bowl_center

	var ellipse_value = (
		(rel.x * rel.x) / (radius_x * radius_x) +
		(rel.y * rel.y) / (radius_y * radius_y)
	)

	if ellipse_value > 0.9:
		var to_center = (bowl_center - global_position).normalized()
		swim_direction = swim_direction.lerp(to_center, 0.15).normalized()

	# ───────── HARD CLAMP (NO GLITCH PUSHING) ─────────
	if ellipse_value > 1.0:
		var scale_factor = 1.0 / sqrt(ellipse_value)
		rel *= scale_factor * 0.98
		global_position = bowl_center + rel

		# IMPORTANT: no bounce, just redirect inward
		swim_direction = (bowl_center - global_position).normalized()

	# ───────── MOVE (KEEP PHYSICS FOR WALL ONLY) ─────────
	velocity = swim_direction * swim_speed
	move_and_slide()

	# ───────── ROTATION ─────────
	var target_angle = swim_direction.angle() + PI / 2

	rotation = lerp_angle(rotation, target_angle, 0.08)
