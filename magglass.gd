extends Node2D

var dragging := false
var drag_offset := Vector2.ZERO

@onready var viewport = $SubViewport
@onready var lens = $TextureRect
@onready var cam = $SubViewport/Camera2D

func _process(delta):
	cam.global_position = global_position

func _ready():
	lens.texture = viewport.get_texture()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if the mouse clicked on this object.
				# Replace 32 with your object's click radius.
				if global_position.distance_to(event.position) < 32:
					dragging = true
					drag_offset = global_position - event.position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = event.position + drag_offset
