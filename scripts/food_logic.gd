extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO

@export var main_menu_mode := false
@export var min_spacing := 1.0
@export var max_speed := 300.0

var dragging := false
var drag_offset := Vector2.ZERO
var drag_target_pos := Vector2.ZERO

const ITEM_GROUP := "bowl_items"

# --- bump/knockback vars ---
var bump_velocity := Vector2.ZERO
@export var bump_strength := 120.0
@export var bump_friction := 6.0   # higher = stops sooner

func _ready():
	if scene_file_path.ends_with("sponge.tscn"):
		scale = Vector2(0.04, 0.04)
	elif scene_file_path.ends_with("algae.tscn"):
		scale = Vector2(0.02, 0.02)
	elif scene_file_path.ends_with("fisheggs.tscn"):
		scale = Vector2(0.04, 0.04)
	var anim := $AnimationPlayer
	if anim.has_animation("swim_animation"):
		anim.play("swim_animation")
	add_to_group(ITEM_GROUP)
	rotation = randf_range(0.0, TAU)
	input_pickable = true

func _on_hit_area_body_entered(body: Node) -> void:
	if body == self:
		return
	if dragging:
		return  # don't get bumped while being held
	# push away from whatever hit it
	var away = (global_position - body.global_position)
	if away.length() < 0.01:
		away = Vector2.RIGHT.rotated(randf() * TAU)  # avoid zero vector if exactly overlapping
	bump_velocity += away.normalized() * bump_strength

# --- dragging ---
# Same approach as fish_swimming_logic.gd: drag via move_and_collide with
# a slide-along-normal remainder, so the existing collision borders/walls
# in the bowl scene stop or deflect the drag exactly like they do for slugs.

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_drag(event.position)

func _unhandled_input(event: InputEvent) -> void:
	if not dragging:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_end_drag()
	elif event is InputEventMouseMotion:
		drag_target_pos = event.position + drag_offset

func _start_drag(mouse_pos: Vector2) -> void:
	dragging = true
	drag_offset = global_position - mouse_pos
	drag_target_pos = global_position
	bump_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	z_index = 10  # draw above the rest while dragging

func _end_drag() -> void:
	dragging = false
	z_index = 0
	bump_velocity = velocity

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

	# decay the bump over time
	bump_velocity = bump_velocity.lerp(Vector2.ZERO, bump_friction * delta)
	velocity = bump_velocity  # + your existing drift velocity if you have one
	move_and_slide()
