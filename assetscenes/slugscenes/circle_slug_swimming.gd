# makes a single slug orbit a target node (e.g. a character's face)
# in a halo-like path: a tilted, flattened ellipse with per-slug
# wobble so a group of these never looks like a perfect ring.
extends CharacterBody2D

# --- what to orbit ---
@export var target_path: NodePath              # path to the face/head node
var target_node: Node2D = null
@export var target_offset := Vector2.ZERO      # fine-tune center point relative to target

# --- halo shape ---
@export var radius_x := 60.0                   # horizontal reach of the halo
@export var radius_y := 20.0                   # vertical reach (small = flatter = more "halo", less "circle")
@export var tilt := -0.15                      # rotates the whole ellipse (radians), gives it perspective

# --- motion ---
@export var orbit_speed := 1.0                 # base radians/sec
@export var clockwise := true
@export var bob_amplitude := 4.0               # up/down bob layered on top of the orbit
@export var bob_frequency := 2.2
@export var radius_wobble := 6.0               # how much the radius itself drifts, breaks up the circle shape
@export var radius_wobble_frequency := 0.6

# --- per-instance variety (set these from the manager, or leave random) ---
@export var phase_offset := -1.0               # -1.0 = randomize on ready
@export var speed_variance := 0.25             # +/- fraction of orbit_speed
@export var scale_multiplier := 1.0

# --- eating (mirrors fish.gd's setup, since swapping the script drops it) ---
var fish_food = null
@export var eat_speed_boost := 0.15   # fraction added to orbit_speed per meal, small "reward" feel
@export var max_meals := 3
var meals_eaten := 0
var base_orbit_speed := 0.0

# --- external management ---
# If true, a manager (e.g. HaloManager) is responsible for configuring
# target_path / phase_offset / etc. BEFORE calling setup() itself.
# Children run _ready() before their parent does in Godot, so without this
# flag this node would call setup() on its own first -- before the manager
# ever gets a chance to set target_path -- locking in a null target_node
# forever (setup() only runs once, guarded by _initialized).
@export var externally_managed := false

var orbit_angle := 0.0
var t := 0.0
var my_speed := 0.0
var noise_seed := 0.0

@onready var swim_animation: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var eat_area: Area2D = $EatArea if has_node("EatArea") else null


var _initialized := false


func _ready() -> void:
	# covers the case where this script is attached before the node
	# enters the tree (normal instantiate-and-add_child flow).
	# Skipped when a manager will call setup() explicitly, since that
	# manager needs to configure this node first (see externally_managed above).
	if not externally_managed and not _initialized:
		setup()


# public entry point -- call this manually after set_script() on a node
# that's already in the tree, since set_script does NOT re-run _ready(),
# and also the entry point managers use for externally_managed nodes.
func setup() -> void:
	if _initialized:
		return
	_initialized = true

	if target_path != NodePath():
		target_node = get_node_or_null(target_path)

	orbit_angle = phase_offset if phase_offset >= 0.0 else randf() * TAU
	t = randf() * TAU
	noise_seed = randf() * TAU

	base_orbit_speed = orbit_speed
	var dir := 1.0 if clockwise else -1.0
	my_speed = orbit_speed * dir * randf_range(1.0 - speed_variance, 1.0 + speed_variance)

	scale *= scale_multiplier

	if swim_animation:
		swim_animation.play("swim_animation")

	_setup_food()
	if eat_area:
		if not eat_area.body_entered.is_connected(_on_eat_area_body_entered):
			eat_area.body_entered.connect(_on_eat_area_body_entered)
	else:
		push_warning("No EatArea node found on: " + scene_file_path)

	_update_position(0.0)


# same species -> food mapping fish.gd uses, so halo slugs still eat correctly
func _setup_food() -> void:
	if scene_file_path.ends_with("caldorid.tscn"):
		fish_food = "Sponge"
	elif scene_file_path.ends_with("sapsucker.tscn"):
		fish_food = "Algae"
	elif scene_file_path.ends_with("hyps.tscn"):
		fish_food = "Sponge"
	elif scene_file_path.ends_with("phyl.tscn"):
		fish_food = "Sponge"
	elif scene_file_path.ends_with("mari.tscn"):
		fish_food = "Sponge"
	elif scene_file_path.ends_with("flab.tscn"):
		fish_food = "Fisheggs"
	elif scene_file_path.ends_with("gonio.tscn"):
		fish_food = "Sponge"
	elif scene_file_path.ends_with("paradisa.tscn"):
		fish_food = "Sponge"


func _on_eat_area_body_entered(body: Node) -> void:
	var food_name = body.scene_file_path.get_file().get_basename().capitalize()
	if food_name == fish_food:
		body.queue_free()
		if meals_eaten < max_meals:
			meals_eaten += 1
			# reward: halo orbit speeds up slightly per meal instead of swim_speed
			my_speed = base_orbit_speed * (1.0 + eat_speed_boost * meals_eaten) * sign(my_speed)


func _physics_process(delta: float) -> void:
	_update_position(delta)


func _update_position(delta: float) -> void:
	if target_node == null:
		return

	orbit_angle = fmod(orbit_angle + my_speed * delta, TAU)
	t += delta

	# organic radius drift, unique per slug via noise_seed, so no two
	# slugs trace the exact same shape even at the same angle
	var r_wobble = sin(t * radius_wobble_frequency + noise_seed) * radius_wobble
	var rx = radius_x + r_wobble
	var ry = radius_y + r_wobble * (radius_y / max(radius_x, 1.0))

	# base ellipse point
	var local_pos := Vector2(cos(orbit_angle) * rx, sin(orbit_angle) * ry)

	# tilt the ellipse for a halo-around-a-head look rather than flat circle
	local_pos = local_pos.rotated(tilt)

	# small independent bob, layered on top
	local_pos.y += sin(t * bob_frequency + noise_seed) * bob_amplitude

	var center := target_node.global_position + target_offset
	var target_world_pos := center + local_pos

	global_position = global_position.lerp(target_world_pos, clamp(delta * 8.0, 0.0, 1.0))

	# face direction of travel (tangent), so the slug doesn't just slide sideways
	var tangent := Vector2(-sin(orbit_angle) * rx, cos(orbit_angle) * ry).rotated(tilt).normalized()
	if tangent.length() > 0.001:
		var target_angle = tangent.angle() * (1.0 if my_speed >= 0.0 else -1.0) + PI / 2
		rotation = lerp_angle(rotation, target_angle, 0.15)
