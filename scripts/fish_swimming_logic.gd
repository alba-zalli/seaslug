# controls the swimming logic of fish
extends CharacterBody2D # TODO: fix flickering and odd bobbing on improved main screen in main

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO
var swim_y := 0.0
var swim_min_y := 0.0
var swim_max_y := 0.0

var swim_time := 0.0

@export var sine_amplitude := 18.0
@export var sine_frequency := 1.2
@export var surface_margin := 40.0

var is_turning := false
var turn_target_angle := 0.0
var turn_speed := 4.0
var speed_multiplier := 1.0
var target_speed_multiplier := 1.0
var bounce_direction := Vector2.RIGHT
var isbettermainmenu := false

#dragging vars 
var dragging := false
var drag_offset := Vector2.ZERO
var drag_target_pos := Vector2.ZERO

var swim_direction := Vector2.RIGHT
var swim_speed := 60.0
var orbit_wobble := 0.0
var wobble_timer := 0.0
var size := 1.0

# store what each fish eats
var fish_food = null

@onready var swim_animation = $AnimationPlayer
@onready var eat_area: Area2D = $EatArea
@export var main_menu_mode := false
var slug_data: SlugData
var base_swim_speed := 60.0
var speed_boost_per_meal := 15.0
var max_meals := 3  
var meals_eaten := 0

# hard upper bound so fish never swim above this many px from the top of
# the screen, no matter what the wave surface reports
@export var ceiling_margin := 20.0

# how far below swim_min_y a fish is allowed to spawn/respawn.
# keeps fish from popping in right at the very top edge of their band,
# even though they can still swim up that high once they're in.
@export var spawn_ceiling_offset := 60.0

func _ready():
	main_menu_mode = _is_better_main_menu()
	isbettermainmenu = main_menu_mode
	print("current_scene path: ", get_tree().current_scene.scene_file_path if get_tree().current_scene else "NULL")
	print("main_menu_mode = ", main_menu_mode)
	base_swim_speed = swim_speed
	if scene_file_path.ends_with("caldorid.tscn"):
		scale = Vector2(0.02 * size, 0.02 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("sapsucker.tscn"):
		scale = Vector2(0.02 * size, 0.02 * size)
		fish_food = "Algae"
	elif scene_file_path.ends_with("hyps.tscn"):
		scale = Vector2(0.2 * size, 0.2 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("phyl.tscn"):
		scale = Vector2(0.07 * size, 0.07 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("mari.tscn"):
		scale = Vector2(0.07 * size, 0.07 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("flab.tscn"):
		scale = Vector2(0.07 * size, 0.07 * size)
		fish_food = "Fisheggs"
	elif scene_file_path.ends_with("gonio.tscn"):
		scale = Vector2(0.05 * size, 0.05 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("paradisa.tscn"):
		scale = Vector2(0.03 * size, 0.03 * size)
		fish_food = "Sponge"

	swim_animation.play("swim_animation")
	if eat_area:
		eat_area.body_entered.connect(_on_eat_area_body_entered)
	else:
		push_warning("No EatArea node found on: " + scene_file_path)

	if main_menu_mode:
		add_to_group("main_menu_fish")

		var screen_size = get_viewport_rect().size
		swim_direction = Vector2.RIGHT if randf() < 0.5 else Vector2.LEFT
		rotation = swim_direction.angle() + PI / 2

		# spawn somewhere on screen, not necessarily at an edge
		var spawn_x = randf_range(0.0, screen_size.x)
		global_position.x = spawn_x
		_reset_wave_band(screen_size)
		var surface = WaveManager.get_surface_y_px(global_position.x)
		swim_y = screen_size.y - 80.0
		

		swim_time = randf() * TAU
		orbit_wobble = randf() * TAU

		sine_amplitude = 100
		sine_frequency = 0.3
		global_position.y = swim_y
		print("MAIN MENYY")
	else:
		swim_direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		rotation = swim_direction.angle() + PI / 2


func _is_clicking_on_fish(mouse_pos: Vector2) -> bool:
	for child in get_children():
		if child is Polygon2D:
			var local_mouse = child.get_global_transform().affine_inverse() * mouse_pos
			if Geometry2D.is_point_in_polygon(local_mouse, child.polygon):
				return true
	return false

func _on_eat_area_body_entered(body: Node) -> void:
	var food_name = body.scene_file_path.get_file().get_basename().capitalize()
	if food_name == fish_food:
		body.queue_free()
		if meals_eaten < max_meals:
			meals_eaten += 1
			swim_speed = base_swim_speed + (speed_boost_per_meal * meals_eaten)

func _input(event):
	if main_menu_mode:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_clicking_on_fish(event.position):
				if event.double_click:
					queue_free()
					return
				if slug_data != null:
					var book_node = get_tree().get_first_node_in_group("book")
					if book_node:
						book_node.open_book_to(slug_data)
				dragging = true
				drag_offset = global_position - event.position
				drag_target_pos = global_position
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		drag_target_pos = event.position + drag_offset

func _process_drag() -> void:
	velocity = Vector2.ZERO
	var motion = drag_target_pos - global_position
	if motion.length() < 0.01:
		return

	var collision := move_and_collide(motion)
	if collision:
		var remaining = collision.get_remainder().slide(collision.get_normal())
		move_and_collide(remaining)

func _physics_process(delta):
	if dragging:
		_process_drag()
		return

	if main_menu_mode:
		_physics_process_main_menu(delta)
	else:
		_physics_process_orbit(delta)
		if not is_turning:
			var target_angle = swim_direction.angle() + PI / 2
			rotation = lerp_angle(rotation, target_angle, 0.08)


# --- helper: recompute the fish's allowed vertical band from the CURRENT
# wave surface at its CURRENT x. Must be called every frame in main menu
# mode since the wave scrolls and the surface height keeps changing. ---
func _reset_wave_band(screen_size: Vector2) -> void:
	var margin = 10.0 + (max(scale.x, scale.y) * 60.0)
	var surface_y = WaveManager.get_surface_y_px(global_position.x)
	# never let the band start above the hard ceiling, even if the wave
	# surface itself is higher up (or WaveManager returns something odd)
	var min_y = max(surface_y + surface_margin, ceiling_margin)
	var max_y = screen_size.y - margin
	if max_y < min_y:
		max_y = min_y
	swim_min_y = min_y
	swim_max_y = max_y


func _pick_spawn_y() -> float:
	var spawn_min_y = swim_min_y + spawn_ceiling_offset
	if spawn_min_y > swim_max_y:
		spawn_min_y = swim_max_y
	return randf_range(spawn_min_y, swim_max_y)


func _physics_process_main_menu(delta):
	var screen_size = get_viewport_rect().size
	var margin = 30.0

	swim_time += delta

	# Horizontal movement
	global_position.x += swim_direction.x * swim_speed * delta

	# Respawn
	if swim_direction.x > 0.0 and global_position.x > screen_size.x + margin:
		_respawn_main_menu_fish(-margin, screen_size)

	elif swim_direction.x < 0.0 and global_position.x < -margin:
		_respawn_main_menu_fish(screen_size.x + margin, screen_size)

	# Current wave height
	var surface = WaveManager.get_surface_y_px(global_position.x)

	# Desired sine motion
	var desired_y = swim_y + sin(swim_time * sine_frequency + orbit_wobble) * sine_amplitude

	# Never let the slug leave the water
	desired_y = max(desired_y, surface + surface_margin)

	# Don't go too low either
	desired_y = min(desired_y, screen_size.y - 30.0)

	global_position.y = lerp(global_position.y, desired_y, 6.0 * delta)

	rotation = lerp_angle(
		rotation,
		swim_direction.angle() + PI/2,
		5.0 * delta
	)


func _respawn_main_menu_fish(spawn_x: float, screen_size: Vector2):

	global_position.x = spawn_x

	var surface = WaveManager.get_surface_y_px(spawn_x)
	
	var size_offset = max(scale.x, scale.y) * 150.0

	swim_y = randf_range(
	surface + 20.0 + size_offset,
	screen_size.y - 100.0
	)

	swim_time = randf() * TAU
	orbit_wobble = randf() * TAU

	sine_amplitude = 5
	sine_frequency = 2

	swim_speed = base_swim_speed + randf_range(-8.0, 8.0)


func _physics_process_orbit(delta):
	wobble_timer += delta

	speed_multiplier = lerp(speed_multiplier, target_speed_multiplier, 3.0 * delta)

	if is_turning:
		rotation = lerp_angle(rotation, turn_target_angle, turn_speed * delta)
		swim_direction = swim_direction.lerp(bounce_direction, 3.0 * delta).normalized()
		velocity = swim_direction * swim_speed * speed_multiplier
		move_and_slide()

		if abs(angle_difference(rotation, turn_target_angle)) < 0.05:
			is_turning = false
			target_speed_multiplier = 1.0
		return

	if randf() < delta * 0.4:
		swim_direction = swim_direction.rotated(randf_range(-0.3, 0.3)).normalized()

	velocity = swim_direction * swim_speed * speed_multiplier
	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		bounce_direction = swim_direction.bounce(collision.get_normal()).normalized()
		turn_target_angle = bounce_direction.angle() + PI / 2
		target_speed_multiplier = 0.4
		is_turning = true
		break

func _is_better_main_menu() -> bool:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return false
	return current_scene.scene_file_path.get_file() == "bettermainmenu.tscn"
