extends CharacterBody2D

var radius_x := 0.0
var radius_y := 0.0
var bowl_center := Vector2.ZERO
var dragging := false
var drag_offset := Vector2.ZERO
var swim_direction := Vector2.RIGHT

# Fish movement variables (replaces JS constructor properties)
var fish_width := 0.0
var fish_height := 0.0
var dx := 0.0
var dy := 0.0

const MIN_FISH_WIDTH := 10.0
const MAX_FISH_WIDTH := 50.0
const MIN_FISH_HEIGHT := 10.0
const MAX_FISH_HEIGHT := 30.0

@onready var swim_animation = $AnimationPlayer

func _ready():
	# your existing scale code stays here...

	# Fish constructor logic (replaces `function fish()` in JS)
	fish_width = randf_range(MIN_FISH_WIDTH, MAX_FISH_WIDTH)
	fish_height = randf_range(MIN_FISH_HEIGHT, MAX_FISH_HEIGHT)
	dx = randf_range(-fish_width, fish_width)
	dy = randf_range(-fish_height, fish_height)

	swim_direction = Vector2.RIGHT.rotated(randf() * TAU)
	swim_animation.play("swim_animation")

# Replaces fish.prototype.move in JS
func move_fish(tank_width: float, tank_height: float):
	position.x += dx + randf_range(-MIN_FISH_WIDTH, MIN_FISH_WIDTH)
	position.y += dy + randf_range(-MIN_FISH_HEIGHT, MIN_FISH_HEIGHT)

	if position.x < 0:
		position.x = 0
		dx = randf_range(-fish_width, fish_width)
	if position.x > tank_width - fish_width:
		position.x = tank_width - fish_width
		dx = randf_range(-fish_width, fish_width)
	if position.y < 0:
		position.y = 0
		dy = randf_range(-fish_height, fish_height)
	if position.y > tank_height - fish_height:
		position.y = tank_height - fish_height
		dy = randf_range(-fish_height, fish_height)

	# Flip sprite based on direction
	if dx < 0:
		scale.x = -abs(scale.x)
	else:
		scale.x = abs(scale.x)
