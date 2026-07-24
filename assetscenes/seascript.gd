extends Area2D

signal region_hovered(dialogue_title: String)

@export var highlight: Sprite2D
@export var dialogue_title: String = ""

func _ready():
	highlight.visible = false
	mouse_entered.connect(_on_enter)
	mouse_exited.connect(_on_exit)

func _on_enter():
	print("Entered")
	highlight.visible = true
	region_hovered.emit(dialogue_title)

func _on_exit():
	print("Exited")
	highlight.visible = false
