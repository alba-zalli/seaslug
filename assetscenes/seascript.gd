extends Area2D

signal region_hovered(dialogue_title: String)

@export var highlight: Sprite2D
@export var dialogue_title: String = ""


static var current_highlight: Sprite2D = null

func _ready():
	print("Highlight =", highlight)
	if highlight == null:
		push_error("Highlight has not been assigned!")
		return
	highlight.visible = false
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)

func _on_enter():
	print("ENTERED: ", dialogue_title)
	print("Mouse position: ", get_global_mouse_position())

	if current_highlight and current_highlight != highlight:
		current_highlight.visible = false

	current_highlight = highlight

	# TEMPORARY TEST
	highlight.visible = true

	print("Hovered region: ", dialogue_title)
	region_hovered.emit(dialogue_title)

func _on_exit():
	print("EXITED FROM: ", dialogue_title)
	print("Mouse position: ", get_global_mouse_position())
