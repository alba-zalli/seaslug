extends Control

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var zoom_camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var container: SubViewportContainer = $SubViewportContainer

var zoom_level := 2.0
var min_zoom := 1.5
var max_zoom := 6.0
var zoom_step := 0.25

func _process(_delta):
	# Keep the lens centered on the mouse cursor
	global_position = get_global_mouse_position() - container.size / 2

	# Point the zoom camera at the same world position the mouse is over,
	# but make sure it's reading from the SAME world, not the lens's own UI layer
	zoom_camera.global_position = get_global_mouse_position()
	zoom_camera.zoom = Vector2.ONE / zoom_level

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_level = clamp(zoom_level + zoom_step, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_level = clamp(zoom_level - zoom_step, min_zoom, max_zoom)
