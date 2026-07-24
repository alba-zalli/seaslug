extends Area2D

signal region_hovered(dialogue_title: String)

@export var highlight: Sprite2D
@export var dialogue_title: String = ""

static var current_highlight: Sprite2D = null

func _ready():
	highlight.visible = false
	
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)

func _on_enter():
	print("Entered")
	if current_highlight and current_highlight != highlight:
		current_highlight.visible = false
	current_highlight = highlight
	highlight.visible = true
	region_hovered.emit(dialogue_title)

func _on_exit():
	print("Exited")
	# Intentionally does nothing — the highlight only turns off
	# once a *different* region's _on_enter fires. This stops the
	# flicker caused by brief/false exits (overlapping collision
	# shapes, the text box grabbing focus, etc.)
