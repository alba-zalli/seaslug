#Alba Z
#June 2026
#Assisted with Claude

extends Node2D

var angle = 10.0
var speed = 0.3
var radius_x = 0 #init
var radius_y = 0
var edge = 0.85
var ellipse_center : Vector2
var ball_size = 20 # diameter of the ball
var time = 0.0
var chaos = 0.7  # 1 is the most chaotic, 0 is the least

func _ready():
	var ellipse = get_parent() # get the polygon ellipse
	radius_x = ellipse.radius_x * edge - ball_size / 2 # set radius of where the fish can swim
	radius_y = ellipse.radius_y * edge - ball_size / 2
	ellipse_center = get_viewport_rect().size / 2

func _process(delta):
	time += delta
	var chaos_x = sin(time * 0.3 + 1.7) * radius_x * chaos * (0.5 + 0.5 * sin(time * 0.7 + 3.1))
	var chaos_y = sin(time * 0.5 + 0.9) * radius_y * chaos * (0.5 + 0.5 * sin(time * 1.1 + 2.4))
	var current_radius_x = clamp(radius_x + chaos_x, 0, radius_x)
	var current_radius_y = clamp(radius_y + chaos_y, 0, radius_y)
	speed = 0.3 + 0.15 * sin(time * 0.2)
	angle += sign(sin(time * 0.05)) * speed * delta
	position = ellipse_center + Vector2(cos(angle) * current_radius_x, sin(angle) * current_radius_y)
