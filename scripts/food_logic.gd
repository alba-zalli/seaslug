extends CharacterBody2D
var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO
@export var main_menu_mode := false
@export var min_spacing := 1.0
@export var max_speed := 300.0
var dragging := false
var drag_offset := Vector2.ZERO
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

func _on_hit_area_body_entered(body: Node) -> void:
	if body == self:
		return
	# push away from whatever hit it
	var away = (global_position - body.global_position)
	if away.length() < 0.01:
		away = Vector2.RIGHT.rotated(randf() * TAU)  # avoid zero vector if exactly overlapping
	bump_velocity += away.normalized() * bump_strength

func _physics_process(delta):
	# decay the bump over time
	bump_velocity = bump_velocity.lerp(Vector2.ZERO, bump_friction * delta)

	velocity = bump_velocity  # + your existing drift velocity if you have one
	move_and_slide()
