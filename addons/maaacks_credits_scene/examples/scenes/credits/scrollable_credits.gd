@tool
extends Control

@onready var credits_label: RichTextLabel = %CreditsLabel

@export var input_scroll_speed: float = 10.0

var _line_number: float = 0.0


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	# Wait until the markdown content and layout are complete.
	call_deferred("_reset_credits_position")


func _on_visibility_changed() -> void:
	if visible:
		call_deferred("_reset_credits_position")


func _reset_credits_position() -> void:
	if not is_instance_valid(credits_label):
		return

	_line_number = 0.0
	credits_label.scroll_to_line(0)
	credits_label.grab_focus()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not visible:
		return

	var input_axis := Input.get_axis("ui_up", "ui_down")

	if abs(input_axis) <= 0.5:
		return

	_line_number += input_axis * delta * input_scroll_speed

	var max_lines := max(
		0,
		credits_label.get_line_count()
		- credits_label.get_visible_line_count()
	)

	_line_number = clamp(_line_number, 0.0, float(max_lines))
	credits_label.scroll_to_line(roundi(_line_number))
