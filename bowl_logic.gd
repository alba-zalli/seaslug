extends Node2D

var scaler = DisplayServer.screen_get_size().y / 175
var radius_x = 80 * scaler
var radius_y = 50 * scaler

var sapsucker_scene = preload("res://sapsucker.tscn")
var caldorid_scene = preload("res://caldorid.tscn")

# spawing swimming creature logic
func spawn_sapsucker():
	var fish = sapsucker_scene.instantiate()
	fish.radius_x = radius_x
	fish.radius_y = radius_y
	add_child(fish)
	
func spawn_caldorid():
	var fish = caldorid_scene.instantiate()
	fish.radius_x = radius_x
	fish.radius_y = radius_y
	add_child(fish)

func _ready():
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var num_points = 64
	var center = DisplayServer.screen_get_size() / 2
	
	for i in range(num_points):
		var angle = (2.0 * PI * i) / num_points
		points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
		
	polygon.polygon = points
	polygon.position = center
	add_child(polygon)


func _on_sapsucker_button_down() -> void:
	spawn_sapsucker()

func _on_cal_dorid_button_down() -> void:
	spawn_caldorid()
