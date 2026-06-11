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

func _ready():
	var ellipse = get_node("../Bowl")
	radius_x = ellipse.radius_x * edge - ball_size / 2
	radius_y = ellipse.radius_y * edge - ball_size / 2
	ellipse_center = get_viewport_rect().size / 2
	scale = Vector2(0.02, 0.02)
	for i in 6:
		c.append(randf_range(0.1, 0.8))

func _process(delta):
	time += delta
	var chaos_x = (sin(time * 0.3173) * c[0]
				+ sin(time * 0.7919) * c[1]
				+ sin(time * 1.4142) * c[2]) * radius_x * chaos
	var chaos_y = (sin(time * 0.5261) * c[3]
				+ sin(time * 1.1180) * c[4]
				+ sin(time * 0.6180) * c[5]) * radius_y * chaos
	var current_radius_x = clamp(radius_x + chaos_x, -radius_x * 0.8, radius_x * 0.8)
	var current_radius_y = clamp(radius_y + chaos_y, -radius_y * 0.8, radius_y * 0.8)
	speed = clamp(0.2 + 0.1 * sin(time * 0.2393), 0.1, 0.25)
	angle += speed * delta
	var prev_pos = position
	position = ellipse_center + Vector2(cos(angle) * current_radius_x, sin(angle) * current_radius_y)
	var direction = position - prev_pos
	if direction.length() > 0.01:
		var target_angle = direction.angle() + PI / 2
		var wiggle = sin(time * 8.0) * 0.15
		rotation = lerp_angle(rotation, target_angle + wiggle, 0.03)
	
