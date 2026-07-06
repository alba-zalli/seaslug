extends Node2D

@export var drag_area_path: NodePath = "Area2D"
@export var smooth_drag: bool = true
@export var drag_speed: float = 20.0

var dragging := false
var drag_offset := Vector2.ZERO
var target_position := Vector2.ZERO
@onready var drag_area: Area2D = get_node(drag_area_path)

func _ready():
	add_to_group("magglass")
	visible = false
	drag_area.input_event.connect(_on_drag_area_input_event)
	target_position = global_position

func toggle_visible(is_visible: bool) -> void:
	visible = is_visible

func _on_drag_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
		else:
			dragging = false

func _unhandled_input(event):
	# Catches mouse release even if it happens outside the Area2D
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func _process(delta):
	if dragging:
		target_position = get_global_mouse_position() + drag_offset
		if smooth_drag:
			global_position = global_position.lerp(target_position, drag_speed * delta)
		else:
			global_position = target_position
