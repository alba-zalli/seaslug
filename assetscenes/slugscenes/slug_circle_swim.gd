# controls sea slugs swimming in a circular (or elliptical) orbit
extends CharacterBody2D

# --- orbit shape ---
@export var bowl_center := Vector2.ZERO      # world-space center of the orbit
@export var radius_x := 80.0                 # horizontal radius
@export var radius_y := 80.0                 # vertical radius (== radius_x for a perfect circle)

# --- orbit motion ---
@export var orbit_speed := 1.2               # radians per second around the circle
@export var clockwise := true                # direction of travel
@export var start_angle_random := true        # randomize starting position on the circle

# --- visual wobble (optional, purely cosmetic) ---
@export var wobble_amplitude := 4.0
@export var wobble_frequency := 3.0

@export var auto_center_on_spawn := false     # if true, treat current position as the center on _ready()

var orbit_angle := 0.0
var wobble_time := 0.0

@onready var swim_animation: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	if auto_center_on_spawn:
		bowl_center = global_position

	orbit_angle = randf() * TAU if start_angle_random else 0.0
	wobble_time = randf() * TAU

	_update_position(0.0)

	if swim_animation:
		swim_animation.play("swim_animation")


func _physics_process(delta: float) -> void:
	_update_position(delta)


func _update_position(delta: float) -> void:
	var dir := 1.0 if clockwise else -1.0
	orbit_angle = fmod(orbit_angle + orbit_speed * dir * delta, TAU)
	wobble_time += delta

	# base point on the ellipse
	var offset := Vector2(cos(orbit_angle) * radius_x, sin(orbit_angle) * radius_y)

	# tiny radial wobble so the motion doesn't look perfectly mechanical
	var wobble := sin(wobble_time * wobble_frequency) * wobble_amplitude
	offset += offset.normalized() * wobble

	var target_pos := bowl_center + offset

	# face the direction of travel (tangent to the ellipse)
	var tangent := Vector2(-sin(orbit_angle) * radius_x, cos(orbit_angle) * radius_y).normalized() * dir
	if tangent.length() > 0.001:
		rotation = tangent.angle() + PI / 2

	global_position = target_pos
