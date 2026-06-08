extends Node2D

var speed = 150.0
var direction = Vector2(1, 0)

func _ready():
	position = Vector2(200, 200)

func _process(delta):
	position += direction * speed * delta
	
	var bounds = get_viewport_rect().size
	if position.x > bounds.x or position.x < 0:
		direction.x *= -1
	if position.y > bounds.y or position.y < 0:
		direction.y *= -1
