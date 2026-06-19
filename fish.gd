#Alba Z
#June 2026
#Assisted with Claude
extends Node2D

var angle = 10.0
var speed = 0.4
var radius_x = 0
var radius_y = 0
var edge = 0.85
var ellipse_center : Vector2
var ball_size = 20
var time = 0.0
var chaos = 0.7
var wiggle_speed = 8.0 
var wiggle_amount = 0.15
var c = [] 

@onready var swim_animation = $AnimationPlayer

func _ready():
	angle = randf() * TAU

	ellipse_center = get_viewport_rect().size / 2
	
	if scene_file_path.ends_with("caldorid.tscn"):
		scale = Vector2(0.035, 0.035)
	elif scene_file_path.ends_with("sapsucker.tscn"):
		scale = Vector2(0.02, 0.02)

	for i in range(6):
		c.append(randf_range(0.1, 0.8))

	swim_animation.play("swim_animation")

func _process(delta):
	time += delta
	var chaos_x = sin(time) * radius_x
	var chaos_y = sin(time) * radius_y
	var current_radius_x = clamp(radius_x, -radius_x * 0.8, radius_x * 0.8)
	var current_radius_y = clamp(radius_y, -radius_y * 0.8, radius_y * 0.8)
	speed = clamp(sin(time), 0.2, 0.25)
	angle += speed * delta
	var prev_pos = position
	position = ellipse_center + Vector2(cos(angle) * current_radius_x, sin(angle) * current_radius_y)
	var direction = position - prev_pos
	if direction.length() > 0.01:
		var target_angle = direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, 0.03)
	
