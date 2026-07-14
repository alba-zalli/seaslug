# controls the swimming logic of fish
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

func _ready():
	base_swim_speed = swim_speed
	if scene_file_path.ends_with("caldorid.tscn"):
		scale = Vector2(0.04 * size, 0.04 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("sapsucker.tscn"):
		scale = Vector2(0.02 * size, 0.02 * size)
		fish_food = "Algea"
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
		fish_food = "Hydroza"
	elif scene_file_path.ends_with("gonio.tscn"):
		scale = Vector2(0.07 * size, 0.07 * size)
		fish_food = "Sponge"
	elif scene_file_path.ends_with("paradisa.tscn"):
		scale = Vector2(0.07 * size, 0.07 * size)
		fish_food = "Sponge"
	orbit_angle = randf() * TAU
	wobble_timer = randf_range(0.0, 3.0)

	# randomize initial heading so fish don't all face the same way
	swim_direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	rotation = swim_direction.angle() + PI / 2   # snap instantly, no lerp delay

	swim_animation.play("swim_animation")
	if eat_area:
		eat_area.body_entered.connect(_on_eat_area_body_entered)
	else:
		push_warning("No EatArea node found on: " + scene_file_path)

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
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		global_position = event.position + drag_offset

func _physics_process(delta):
	if dragging:
		velocity = Vector2.ZERO
		return

	if main_menu_mode:
		_physics_process_main_menu(delta)
	else:
		_physics_process_orbit(delta)

	# face direction of travel
	var target_angle = swim_direction.angle() + PI / 2
	rotation = lerp_angle(rotation, target_angle, 0.08)

func _physics_process_main_menu(delta):
	var screen_size = get_viewport_rect().size
	var margin = 40.0 + (max(scale.x, scale.y) * 60.0)  # scale margin with fish size

	# compute a "steer toward center" vector, stronger the closer we are to an edge
	var steer := Vector2.ZERO
	var edge_dist = margin * 2.5  # start steering before actually hitting margin

	if global_position.x < edge_dist:
		steer.x += (edge_dist - global_position.x) / edge_dist
	elif global_position.x > screen_size.x - edge_dist:
		steer.x -= (edge_dist - (screen_size.x - global_position.x)) / edge_dist

	if global_position.y < edge_dist:
		steer.y += (edge_dist - global_position.y) / edge_dist
	elif global_position.y > screen_size.y - edge_dist:
		steer.y -= (edge_dist - (screen_size.y - global_position.y)) / edge_dist

	if steer != Vector2.ZERO:
		# blend current direction toward the steer vector smoothly
		swim_direction = swim_direction.lerp(steer.normalized(), 3.0 * delta).normalized()
	else:
		# occasionally wander a little when not near an edge
		if randf() < delta * 0.3:
			swim_direction = swim_direction.rotated(randf_range(-0.3, 0.3)).normalized()

	velocity = swim_direction * swim_speed
	move_and_slide()

	# hard safety clamp so fish never actually leaves the screen
	global_position.x = clamp(global_position.x, margin * 0.5, screen_size.x - margin * 0.5)
	global_position.y = clamp(global_position.y, margin * 0.5, screen_size.y - margin * 0.5)


func _physics_process_orbit(delta):
	# advance the orbit angle — this drives the circular path
	var orbit_speed : float = swim_speed / (0.75 * min(radius_x, radius_y))
	orbit_angle += orbit_speed * delta

	# wobble: slowly drifts the fish inward/outward around 75% of the bowl radius
	wobble_timer += delta
	orbit_wobble = sin(wobble_timer * 0.4) * 0.15   # ±15% radius drift, very slow

	var orbit_radius_x = radius_x * (0.75 + orbit_wobble)
	var orbit_radius_y = radius_y * (0.75 + orbit_wobble)

	# target position on the elliptical orbit
	var target_pos = bowl_center + Vector2(
		cos(orbit_angle) * orbit_radius_x,
		sin(orbit_angle) * orbit_radius_y
	)

	# steer smoothly toward the orbit point rather than teleporting
	var to_target = (target_pos - global_position)
	swim_direction = swim_direction.lerp(to_target.normalized(), 6.0 * delta).normalized()

	velocity = swim_direction * swim_speed
	move_and_slide()

	# hard clamp after move_and_slide so physics never pushes outside
	var rel = global_position - bowl_center
	if radius_x > 0 and radius_y > 0:
		var ellipse_value = (rel.x * rel.x) / (radius_x * radius_x) + (rel.y * rel.y) / (radius_y * radius_y)
		if ellipse_value > 1.0:
			global_position = bowl_center + rel * (1.0 / sqrt(ellipse_value)) * 0.99
			swim_direction = (bowl_center - global_position).normalized()
