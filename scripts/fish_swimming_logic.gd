# Controls the swimming logic of sea slugs.
extends CharacterBody2D


# -------------------------------------------------------------------
# Bowl boundaries
# -------------------------------------------------------------------

var radius_x: float = 0.0
var radius_y: float = 0.0
var bowl_center: Vector2 = Vector2.ZERO


# -------------------------------------------------------------------
# Main-menu swimming
# -------------------------------------------------------------------

var swim_y: float = 0.0
var swim_min_y: float = 0.0
var swim_max_y: float = 0.0
var swim_time: float = 0.0

@export var sine_amplitude: float = 8.0
@export var sine_frequency: float = 7.7
@export var surface_margin: float = 60.0

@export var ceiling_margin: float = 20.0
@export var spawn_ceiling_offset: float = 60.0


# -------------------------------------------------------------------
# Appearance
# -------------------------------------------------------------------

@export_group("Appearance")

@export var min_size: float = 0.8
@export var max_size: float = 1.0

@export var enable_random_tint: bool = true
@export var tint_min: float = 0.7
@export var tint_max: float = 1.2

@export_range(0.0, 1.0)
var tint_strength: float = 0.25

var size: float = 1.0
var slug_tint: Color = Color.WHITE


# -------------------------------------------------------------------
# Swimming
# -------------------------------------------------------------------

@export_group("Swimming")

@export var swim_speed: float = 60.0
@export var turn_speed: float = 4.0

## Lower acceleration produces slower, heavier movement.
@export var acceleration: float = 45.0

## Hard speed limit.
@export var maximum_swim_speed: float = 85.0

## How often random wandering occurs.
@export var wandering_frequency: float = 0.4

## Maximum random turn in radians.
@export var wandering_angle: float = 0.3

var swim_direction: Vector2 = Vector2.RIGHT
var orbit_wobble: float = 0.0
var wobble_timer: float = 0.0

var speed_multiplier: float = 1.0
var target_speed_multiplier: float = 1.0
var base_swim_speed: float = 60.0


# -------------------------------------------------------------------
# Gentle slug separation
# -------------------------------------------------------------------

@export_group("Slug Avoidance")

## Distance where slugs begin steering apart.
@export var separation_radius: float = 120.0

## Strength of the separation direction.
@export var separation_strength: float = 1.0

## How gradually steering changes direction.
@export var direction_smoothing: float = 1.4


# -------------------------------------------------------------------
# Physical collision response
# -------------------------------------------------------------------

@export_group("Collision Response")

## Strength of turning away from a collision.
@export var collision_turn_strength: float = 0.7

## Duration for which the collision direction remains active.
@export var collision_memory_duration: float = 0.35

## Amount of speed retained after a collision.
@export_range(0.0, 1.0)
var collision_speed_retention: float = 0.55

## Prevents repeated slowdown every physics frame during one collision.
@export var collision_slowdown_cooldown: float = 0.12

## How slowly physics-adjusted velocity influences facing direction.
@export var velocity_direction_smoothing: float = 0.8

var collision_avoidance_direction: Vector2 = Vector2.ZERO
var collision_memory_timer: float = 0.0
var collision_cooldown: float = 0.0


# -------------------------------------------------------------------
# Dragging
# -------------------------------------------------------------------

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var drag_target_pos: Vector2 = Vector2.ZERO


# -------------------------------------------------------------------
# Eating
# -------------------------------------------------------------------

@export_group("Eating")

@export var speed_boost_per_meal: float = 5.0
@export var max_meals: int = 3

var fish_food: Variant = null
var meals_eaten: int = 0

var slug_data: SlugData


# -------------------------------------------------------------------
# Scene mode and nodes
# -------------------------------------------------------------------

@export var main_menu_mode: bool = false

var is_better_main_menu: bool = false

@onready var swim_animation: AnimationPlayer = $AnimationPlayer
@onready var eat_area: Area2D = $EatArea


func _ready() -> void:
	# Keep physical collisions enabled, but reduce aggressive overlap recovery.
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.001
	max_slides = 2

	size = randf_range(min_size, max_size)
	randomize_slug_tint()

	main_menu_mode = _is_better_main_menu()
	is_better_main_menu = main_menu_mode

	base_swim_speed = swim_speed

	print(
		"current_scene path: ",
		get_tree().current_scene.scene_file_path
		if get_tree().current_scene
		else "NULL"
	)

	print("main_menu_mode = ", main_menu_mode)

	_configure_slug_type()

	if swim_animation != null:
		swim_animation.play("swim_animation")

	if eat_area != null:
		if not eat_area.body_entered.is_connected(
			_on_eat_area_body_entered
		):
			eat_area.body_entered.connect(
				_on_eat_area_body_entered
			)
	else:
		push_warning(
			"No EatArea node found on: "
			+ scene_file_path
		)

	if main_menu_mode:
		_initialize_main_menu_swimming()
	else:
		_initialize_bowl_swimming()


func _configure_slug_type() -> void:
	if is_better_main_menu:
		size *= 2.0

		if scene_file_path.ends_with("caldorid.tscn"):
			scale = Vector2(0.01, 0.01) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("sapsucker.tscn"):
			scale = Vector2(0.01, 0.01) * size
			fish_food = "Algae"

		elif scene_file_path.ends_with("hyps.tscn"):
			scale = Vector2(0.1, 0.1) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("phyl.tscn"):
			scale = Vector2(0.04, 0.04) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("mari.tscn"):
			scale = Vector2(0.04, 0.04) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("flab.tscn"):
			scale = Vector2(0.04, 0.04) * size
			fish_food = "Fisheggs"

		elif scene_file_path.ends_with("gonio.tscn"):
			scale = Vector2(0.025, 0.025) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("paradisa.tscn"):
			scale = Vector2(0.015, 0.015) * size
			fish_food = "Sponge"

	else:
		if scene_file_path.ends_with("caldorid.tscn"):
			scale = Vector2(0.04, 0.04) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("sapsucker.tscn"):
			scale = Vector2(0.02, 0.02) * size
			fish_food = "Algae"

		elif scene_file_path.ends_with("hyps.tscn"):
			scale = Vector2(0.2, 0.2) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("phyl.tscn"):
			scale = Vector2(0.05, 0.05) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("mari.tscn"):
			scale = Vector2(0.07, 0.07) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("flab.tscn"):
			scale = Vector2(0.07, 0.07) * size
			fish_food = "Fisheggs"

		elif scene_file_path.ends_with("gonio.tscn"):
			scale = Vector2(0.05, 0.05) * size
			fish_food = "Sponge"

		elif scene_file_path.ends_with("paradisa.tscn"):
			scale = Vector2(0.07, 0.07) * size
			fish_food = "Sponge"


func _initialize_main_menu_swimming() -> void:
	add_to_group("main_menu_fish")

	var screen_size: Vector2 = get_viewport_rect().size

	if randf() < 0.5:
		swim_direction = Vector2.RIGHT
	else:
		swim_direction = Vector2.LEFT

	rotation = swim_direction.angle() + PI / 2.0

	global_position.x = randf_range(
		0.0,
		screen_size.x
	)

	_reset_wave_band(screen_size)

	swim_y = screen_size.y - 10.0
	swim_time = randf() * TAU
	orbit_wobble = randf() * TAU

	sine_amplitude = 50.0
	sine_frequency = 0.8

	global_position.y = swim_y


func _initialize_bowl_swimming() -> void:
	swim_direction = Vector2.RIGHT.rotated(
		randf_range(0.0, TAU)
	).normalized()

	rotation = swim_direction.angle() + PI / 2.0


func randomize_slug_tint() -> void:
	if not enable_random_tint:
		return

	var tint: Color = Color(
		randf_range(tint_min, tint_max),
		randf_range(tint_min, tint_max),
		randf_range(tint_min, tint_max),
		1.0
	)

	modulate = Color(
		lerp(1.0, tint.r, tint_strength),
		lerp(1.0, tint.g, tint_strength),
		lerp(1.0, tint.b, tint_strength),
		1.0
	)

	slug_tint = modulate


func _get_separation_direction() -> Vector2:
	var separation: Vector2 = Vector2.ZERO
	var nearby_count: int = 0

	for node: Node in get_tree().get_nodes_in_group("slug"):
		if node == self:
			continue

		if not is_instance_valid(node):
			continue

		if not node is Node2D:
			continue

		var other: Node2D = node as Node2D

		var offset: Vector2 = (
			global_position
			- other.global_position
		)

		var distance: float = offset.length()

		if distance <= 0.001:
			separation += Vector2.RIGHT.rotated(
				randf_range(0.0, TAU)
			)

			nearby_count += 1
			continue

		if distance < separation_radius:
			var closeness: float = (
				1.0
				- distance / separation_radius
			)

			# Strongest only when slugs are very close.
			closeness *= closeness

			separation += (
				offset.normalized()
				* closeness
			)

			nearby_count += 1

	if nearby_count <= 0:
		return Vector2.ZERO

	return separation / float(nearby_count)


func _is_clicking_on_fish(
	mouse_pos: Vector2
) -> bool:
	for child: Node in get_children():
		if child is Polygon2D:
			var polygon_child: Polygon2D = (
				child as Polygon2D
			)

			var local_mouse: Vector2 = (
				polygon_child
					.get_global_transform()
					.affine_inverse()
				* mouse_pos
			)

			if Geometry2D.is_point_in_polygon(
				local_mouse,
				polygon_child.polygon
			):
				return true

	return false


func _on_eat_area_body_entered(
	body: Node
) -> void:
	if body == null:
		return

	var food_name: String = (
		body.scene_file_path
			.get_file()
			.get_basename()
			.capitalize()
	)

	if food_name != fish_food:
		return

	body.queue_free()

	if meals_eaten >= max_meals:
		return

	meals_eaten += 1

	swim_speed = min(
		base_swim_speed
			+ speed_boost_per_meal
			* float(meals_eaten),
		maximum_swim_speed
	)


func _input(event: InputEvent) -> void:
	if main_menu_mode:
		return

	if (
		event is InputEventMouseButton
		and event.button_index
			== MOUSE_BUTTON_LEFT
	):
		var mouse_button: InputEventMouseButton = (
			event as InputEventMouseButton
		)

		if mouse_button.pressed:
			if _is_clicking_on_fish(
				mouse_button.position
			):
				if mouse_button.double_click:
					queue_free()
					return

				if slug_data != null:
					var book_node: Node = (
						get_tree()
							.get_first_node_in_group(
								"book"
							)
					)

					if book_node != null:
						book_node.open_book_to(
							slug_data
						)

				dragging = true

				drag_offset = (
					global_position
					- mouse_button.position
				)

				drag_target_pos = global_position
		else:
			dragging = false

	elif (
		event is InputEventMouseMotion
		and dragging
	):
		var mouse_motion: InputEventMouseMotion = (
			event as InputEventMouseMotion
		)

		drag_target_pos = (
			mouse_motion.position
			+ drag_offset
		)


func _process_drag() -> void:
	velocity = Vector2.ZERO

	var motion: Vector2 = (
		drag_target_pos
		- global_position
	)

	if motion.length() < 0.01:
		return

	var collision: KinematicCollision2D = (
		move_and_collide(motion)
	)

	if collision != null:
		var remaining: Vector2 = (
			collision
				.get_remainder()
				.slide(
					collision.get_normal()
				)
		)

		move_and_collide(remaining)


func _physics_process(delta: float) -> void:
	if dragging:
		_process_drag()
		return

	if main_menu_mode:
		_physics_process_main_menu(delta)
	else:
		_physics_process_orbit(delta)
		_keep_inside_ellipse()


func _reset_wave_band(
	screen_size: Vector2
) -> void:
	var margin: float = (
		max(scale.x, scale.y)
		* 60.0
	) + 200.0

	var surface_y: float = (
		WaveManager.get_surface_y_px(
			global_position.x
		)
		+ 100.0
	)

	var min_y: float = max(
		surface_y + surface_margin,
		ceiling_margin
	)

	var max_y: float = (
		screen_size.y
		- margin
	)

	if max_y < min_y:
		max_y = min_y

	swim_min_y = min_y
	swim_max_y = max_y


func _pick_spawn_y() -> float:
	var spawn_min_y: float = (
		swim_min_y
		+ spawn_ceiling_offset
	)

	if spawn_min_y > swim_max_y:
		spawn_min_y = swim_max_y

	return randf_range(
		spawn_min_y,
		swim_max_y
	)


func _keep_inside_ellipse() -> void:
	if radius_x <= 0.0 or radius_y <= 0.0:
		return

	var offset: Vector2 = (
		global_position
		- bowl_center
	)

	var ellipse_check: float = (
		(offset.x * offset.x)
		/ (radius_x * radius_x)
		+
		(offset.y * offset.y)
		/ (radius_y * radius_y)
	)

	if ellipse_check <= 1.0:
		return

	var angle: float = atan2(
		offset.y / radius_y,
		offset.x / radius_x
	)

	global_position = (
		bowl_center
		+ Vector2(
			cos(angle) * radius_x,
			sin(angle) * radius_y
		)
	)

	var inward_direction: Vector2 = (
		bowl_center
		- global_position
	).normalized()

	var inward_blend: Vector2 = (
		swim_direction.lerp(
			inward_direction,
			0.25
		)
	)

	if inward_blend.length_squared() > 0.0001:
		swim_direction = inward_blend.normalized()


func _physics_process_main_menu(
	delta: float
) -> void:
	var screen_size: Vector2 = (
		get_viewport_rect().size
	)

	var margin: float = 200.0

	swim_time += delta

	global_position.x += (
		swim_direction.x
		* swim_speed
		* delta
	)

	if (
		swim_direction.x > 0.0
		and global_position.x
			> screen_size.x + margin
	):
		_respawn_main_menu_fish(
			-margin,
			screen_size
		)

	elif (
		swim_direction.x < 0.0
		and global_position.x < -margin
	):
		_respawn_main_menu_fish(
			screen_size.x + margin,
			screen_size
		)

	var surface: float = (
		WaveManager.get_surface_y_px(
			global_position.x
		)
		- 40.0
	)

	var desired_y: float = (
		swim_y
		+ sin(
			swim_time * sine_frequency
			+ orbit_wobble
		) * sine_amplitude
	)

	desired_y = max(
		desired_y,
		surface + surface_margin
	)

	desired_y = min(
		desired_y,
		screen_size.y - 30.0
	)

	global_position.y = lerp(
		global_position.y,
		desired_y,
		clamp(
			6.0 * delta,
			0.0,
			1.0
		)
	)

	rotation = lerp_angle(
		rotation,
		swim_direction.angle()
			+ PI / 2.0,
		clamp(
			5.0 * delta,
			0.0,
			1.0
		)
	)


func _respawn_main_menu_fish(
	spawn_x: float,
	screen_size: Vector2
) -> void:
	global_position.x = spawn_x
	swim_y = screen_size.y - 10.0

	swim_time = randf() * TAU
	orbit_wobble = randf() * TAU

	sine_amplitude = 50.0
	sine_frequency = 0.8

	swim_speed = clamp(
		base_swim_speed
			+ randf_range(-8.0, 8.0),
		1.0,
		maximum_swim_speed
	)


func _physics_process_orbit(
	delta: float
) -> void:
	wobble_timer += delta

	collision_cooldown = max(
		collision_cooldown - delta,
		0.0
	)

	speed_multiplier = move_toward(
		speed_multiplier,
		target_speed_multiplier,
		3.0 * delta
	)

	if randf() < delta * wandering_frequency:
		swim_direction = (
			swim_direction
				.rotated(
					randf_range(
						-wandering_angle,
						wandering_angle
					)
				)
				.normalized()
		)

	var desired_direction: Vector2 = (
		swim_direction
	)

	var separation: Vector2 = (
		_get_separation_direction()
	)

	if separation.length_squared() > 0.0001:
		var separation_direction: Vector2 = (
			desired_direction
			+ separation
				* separation_strength
		)

		if (
			separation_direction.length_squared()
			> 0.0001
		):
			desired_direction = (
				separation_direction.normalized()
			)

	if collision_memory_timer > 0.0:
		collision_memory_timer = max(
			collision_memory_timer - delta,
			0.0
		)

		if (
			collision_avoidance_direction
				.length_squared()
			> 0.0001
		):
			var collision_steering: Vector2 = (
				desired_direction
				+ collision_avoidance_direction
					* collision_turn_strength
			)

			if (
				collision_steering.length_squared()
				> 0.0001
			):
				desired_direction = (
					collision_steering.normalized()
				)
	else:
		collision_avoidance_direction = (
			Vector2.ZERO
		)

	var direction_blend: Vector2 = (
		swim_direction.lerp(
			desired_direction,
			clamp(
				direction_smoothing * delta,
				0.0,
				1.0
			)
		)
	)

	if direction_blend.length_squared() > 0.0001:
		swim_direction = (
			direction_blend.normalized()
		)

	var desired_speed: float = min(
		swim_speed * speed_multiplier,
		maximum_swim_speed
	)

	var target_velocity: Vector2 = (
		swim_direction
		* desired_speed
	)

	velocity = velocity.move_toward(
		target_velocity,
		acceleration * delta
	)

	velocity = velocity.limit_length(
		maximum_swim_speed
	)

	move_and_slide()

	_process_slide_collisions()

	# Physics overlap recovery can change velocity.
	# Keep the final speed controlled.
	velocity = velocity.limit_length(
		maximum_swim_speed
	)

	# Do not instantly copy a collision correction into swim_direction.
	if velocity.length_squared() > 0.0001:
		var velocity_direction: Vector2 = (
			velocity.normalized()
		)

		var velocity_blend: Vector2 = (
			swim_direction.lerp(
				velocity_direction,
				clamp(
					velocity_direction_smoothing
						* delta,
					0.0,
					1.0
				)
			)
		)

		if velocity_blend.length_squared() > 0.0001:
			swim_direction = (
				velocity_blend.normalized()
			)

	var target_angle: float = (
		swim_direction.angle()
		+ PI / 2.0
	)

	rotation = lerp_angle(
		rotation,
		target_angle,
		clamp(
			turn_speed * delta,
			0.0,
			1.0
		)
	)


func _process_slide_collisions() -> void:
	var collision_count: int = (
		get_slide_collision_count()
	)

	if collision_count <= 0:
		return

	var combined_normal: Vector2 = (
		Vector2.ZERO
	)

	for index: int in range(
		collision_count
	):
		var collision: KinematicCollision2D = (
			get_slide_collision(index)
		)

		if collision == null:
			continue

		var collision_normal: Vector2 = (
			collision.get_normal()
		)

		if (
			collision_normal.length_squared()
			<= 0.0001
		):
			continue

		combined_normal += collision_normal

	if combined_normal.length_squared() <= 0.0001:
		return

	# Store the direction but do not snap the slug immediately.
	collision_avoidance_direction = (
		combined_normal.normalized()
	)

	collision_memory_timer = (
		collision_memory_duration
	)

	# Only reduce speed once during a short continuous contact.
	if collision_cooldown > 0.0:
		return

	var retained_speed: float = (
		velocity.length()
		* collision_speed_retention
	)

	retained_speed = clamp(
		retained_speed,
		0.0,
		maximum_swim_speed
	)

	if velocity.length_squared() > 0.0001:
		velocity = (
			velocity.normalized()
			* retained_speed
		)
	else:
		velocity = Vector2.ZERO

	collision_cooldown = (
		collision_slowdown_cooldown
	)


func _is_better_main_menu() -> bool:
	var current_scene: Node = (
		get_tree().current_scene
	)

	if current_scene == null:
		return false

	return (
		current_scene.scene_file_path
			.get_file()
		== "bettermainmenu.tscn"
	)
